# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "upload_guard_workshop"

require "minitest/autorun"

module UploadFixtureHelpers
  Upload = Struct.new(:original_filename, :content_type, :byte_size, :path, keyword_init: true) do
    alias_method :size, :byte_size
  end

  def fixture_upload(filename, content_type:, size: nil)
    path = fixture_path_for(filename)
    size ||= File.size(path)

    Upload.new(
      original_filename: filename,
      content_type: content_type,
      byte_size: size,
      path: path
    )
  end

  private

  def fixture_path_for(filename)
    fixture_name = File.basename(filename)
    fixture_name = "company-logo.png" if fixture_name == "logo.png"

    File.expand_path("fixtures/files/#{fixture_name}", __dir__)
  end
end
