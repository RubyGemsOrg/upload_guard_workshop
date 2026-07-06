# frozen_string_literal: true

require "test_helper"

class TestUploadGuardWorkshop < Minitest::Test
  include UploadFixtureHelpers

  def test_that_it_has_a_version_number
    refute_nil ::UploadGuard::VERSION
  end

  def test_logo_guard_accepts_a_small_png_logo
    upload = fixture_upload("company-logo.png", content_type: "image/png")

    result = UploadGuard::Guard.logo.validate(upload)

    assert_predicate result, :accepted?
    assert_equal "company-logo.png", result.filename
    assert_empty result.errors
  end

  def test_logo_guard_rejects_disallowed_content_type
    upload = fixture_upload("company-logo.gif", content_type: "image/gif")

    result = UploadGuard::Guard.logo.validate(upload)

    refute_predicate result, :accepted?
    assert_includes result.errors, "content type is not allowed"
  end

  def test_invoice_guard_accepts_a_small_pdf
    upload = fixture_upload("invoice-1001.pdf", content_type: "application/pdf")

    assert UploadGuard::Guard.invoice_pdf.accepted?(upload)
  end

  def test_invoice_guard_rejects_large_pdf
    upload = fixture_upload("invoice-1001.pdf", content_type: "application/pdf", size: 12 * 1024 * 1024)

    result = UploadGuard::Guard.invoice_pdf.validate(upload)

    refute_predicate result, :accepted?
    assert_includes result.errors, "file is too large"
  end
end
