# frozen_string_literal: true

# Lab 2 stretch - Findings #2 and #3, and how #3 amplifies #1.
#
# Run this from the repository root:
#
#   bundle exec ruby -Ilib labs/lab2/reproduce_findings_2_and_3.rb
#
#   Finding #2 (Medium) - content_type_allowed?/image?/document? trust the
#                         client-supplied content_type header.
#   Finding #3 (Medium) - extension_allowed? substring-matches the filename
#                         instead of comparing the final extension.
#
# This script only reads fixtures and does path arithmetic. It writes nothing.

require "upload_guard_workshop"

FIXTURES = File.expand_path("../../test/fixtures/files", __dir__)

# Stand-in for ActionDispatch::Http::UploadedFile.
FakeUpload = Struct.new(:original_filename, :content_type, :byte_size) do
  alias_method :size, :byte_size
end

def section(title)
  puts
  puts "== #{title} =="
end

def fixture(filename, content_type)
  path = File.join(FIXTURES, filename)
  FakeUpload.new(filename, content_type, File.size(path))
end

section "Finding #2 - the gem believes whatever content_type the client sends"
liar = fixture("not-really-a-logo.png", "image/png")
first_bytes = File.read(File.join(FIXTURES, "not-really-a-logo.png"), 32)
puts "fixture            => not-really-a-logo.png"
puts "actual file bytes  => #{first_bytes.inspect}"
puts "declared type      => image/png"
puts "logo.accepted?     => #{UploadGuard::Guard.logo.accepted?(liar)}"
puts "logo.image?        => #{UploadGuard::Guard.logo.image?(liar)}"
puts
puts "The bytes are text. The gem never looks at them - it only reads the"
puts "content_type string the uploader chose."

section "Finding #3 - the extension allowlist is a substring search"
double = fixture("invoice.pdf.exe", "application/pdf")
result = UploadGuard::Guard.invoice_pdf.validate(double)
puts "fixture                 => invoice.pdf.exe"
puts "invoice_pdf allowlist   => #{UploadGuard::Guard.invoice_pdf.allowed_extensions.inspect}"
puts "accepted?               => #{result.accepted?}"
puts "errors                  => #{result.errors.inspect}"
puts
puts %(extension_allowed? asks `filename.index(".pdf")`, which finds ".pdf" at)
puts "offset 7 and stops caring. The real extension is .exe."

section "How #3 amplifies #1 - which traversal payloads survive validation?"
base_dir = "/srv/uploads/company_logos"
guard = UploadGuard::Guard.logo
payloads = [
  "../../../../etc/passwd",
  "../../../../tmp/uploads/../pwned.txt",
  "../../../../tmp/pwned.png",
  "../../../../etc/cron.d/evil.png",
  "../../.png/../../../../etc/cron.d/pwn"
]

puts "#{"UPLOADED FILENAME".ljust(40)} #{"ACCEPTED".ljust(9)} STORAGE PATH RESOLVES TO"
puts "-" * 96
payloads.each do |name|
  upload = FakeUpload.new(name, "image/png", 10)
  accepted = guard.validate(upload).accepted?
  resolved = File.expand_path(guard.storage_path(base_dir, upload))
  puts "#{name.ljust(40)} #{accepted.to_s.ljust(9)} #{resolved}"
end

puts
puts "Read the last row carefully. Because .png only has to appear SOMEWHERE in"
puts "the string, an attacker can write a file with no extension at all, under"
puts "any name, anywhere on disk. Finding #3 is what makes Finding #1 general."
puts
puts "Also note row 1: /etc/passwd is REJECTED. If your prediction was a path"
puts "without an allowed extension in it, validation stops you - and Finding #1"
puts "can look like a false positive. It is not. The extension check is the only"
puts "thing standing there, and #3 removes it."

section "Discuss"
puts "1. Are #2 and #3 real? Reachable? What does the host have to do first?"
puts "2. Does your Finding #1 patch fix either of them? (Try it.)"
puts "3. Which of the four moves would you make: fix, mitigate, document, dismiss?"
