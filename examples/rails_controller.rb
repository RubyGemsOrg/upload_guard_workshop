# frozen_string_literal: true

# Rails-flavored host application sketch for the workshop scenarios.
class CompanyUploadsController < ApplicationController
  def update_logo
    handle_upload(
      params.require(:company).fetch(:logo),
      UploadGuard::Guard.logo,
      Rails.root.join("tmp/uploads/company_logos"),
      success: company_path,
      failure: edit_company_path,
      message: "Logo uploaded"
    )
  end

  def attach_invoice
    handle_upload(
      params.require(:invoice).fetch(:pdf),
      UploadGuard::Guard.invoice_pdf,
      Rails.root.join("tmp/uploads/invoices"),
      success: invoices_path,
      failure: new_invoice_path,
      message: "Invoice queued"
    ) do |path|
      InvoiceImportJob.perform_later(path.to_s)
    end
  end

  private

  def handle_upload(upload, guard, directory, options)
    result = guard.validate(upload)
    if result.accepted?
      path = guard.storage_path(directory, upload)
      File.binwrite(path, upload.read)
      yield path if block_given?
      redirect_to options.fetch(:success), notice: options.fetch(:message)
    else
      redirect_to options.fetch(:failure), alert: result.errors.join(", ")
    end
  end
end
