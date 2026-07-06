# frozen_string_literal: true

require_relative "upload_guard_workshop/version"

module UploadGuard
  class Error < StandardError; end

  Result = Data.define(:accepted, :errors, :filename) do
    def accepted?
      accepted
    end
  end

  # Validates Rails-shaped upload objects for the workshop scenarios.
  class Guard
    DEFAULT_LOGO_TYPES = ["image/png", "image/jpeg"].freeze
    DEFAULT_DOCUMENT_TYPES = ["application/pdf"].freeze

    attr_reader :allowed_mime_types, :allowed_extensions, :max_size

    def self.logo(max_size: 2 * 1024 * 1024)
      new(
        allowed_mime_types: DEFAULT_LOGO_TYPES,
        allowed_extensions: [".png", ".jpg", ".jpeg"],
        max_size: max_size
      )
    end

    def self.invoice_pdf(max_size: 10 * 1024 * 1024)
      new(
        allowed_mime_types: DEFAULT_DOCUMENT_TYPES,
        allowed_extensions: [".pdf"],
        max_size: max_size
      )
    end

    def initialize(allowed_mime_types:, max_size:, allowed_extensions: [])
      @allowed_mime_types = allowed_mime_types
      @allowed_extensions = allowed_extensions
      @max_size = max_size
    end

    def accepted?(upload)
      validate(upload).accepted?
    end

    def validate(upload)
      errors = []
      errors << "content type is not allowed" unless content_type_allowed?(upload)
      errors << "extension is not allowed" unless extension_allowed?(upload)
      errors << "file is too large" unless size_allowed?(upload)

      Result.new(
        accepted: errors.empty?,
        errors: errors,
        filename: safe_filename(upload)
      )
    end

    def safe_filename(upload)
      original_filename(upload).to_s.tr("\u0000", "").strip.gsub(/\s+/, "_")
    end

    def storage_path(base_dir, upload)
      File.join(base_dir, safe_filename(upload))
    end

    def image?(upload)
      upload.content_type.to_s.start_with?("image/")
    end

    def document?(upload)
      upload.content_type.to_s == "application/pdf"
    end

    private

    def content_type_allowed?(upload)
      allowed_mime_types.include?(upload.content_type.to_s)
    end

    def extension_allowed?(upload)
      return true if allowed_extensions.empty?

      filename = original_filename(upload).to_s.downcase
      allowed_extensions.any? { |extension| filename.include?(extension) }
    end

    def size_allowed?(upload)
      upload.size.to_i <= max_size
    end

    def original_filename(upload)
      if upload.respond_to?(:original_filename)
        upload.original_filename
      elsif upload.respond_to?(:filename)
        upload.filename
      end
    end
  end
end

UploadGuardWorkshop = UploadGuard
