# frozen_string_literal: true

# PROTOTYPE: A single-file Rails app that shows how UploadGuard handles a
# drag-and-drop upload. The app validates files in memory and never stores them.

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "rails", "~> 8.1"
  gem "puma", ">= 6"
end

require "action_controller/railtie"
require "rackup"
require_relative "../lib/upload_guard_workshop"

# Minimal Rails application used only by the local workshop prototype.
class UploadGuardDemo < Rails::Application
  config.root = __dir__
  config.eager_load = false
  config.consider_all_requests_local = true
  config.secret_key_base = "upload-guard-workshop-local-demo"
  config.session_store :cookie_store, key: "_upload_guard_demo"
  config.logger = ActiveSupport::Logger.new($stdout)
  config.log_level = :warn
end

# The prototype's single controller and its inline view templates.
# rubocop:disable Metrics/ClassLength, Style/OneClassPerFile
class UploadsController < ActionController::Base
  protect_from_forgery with: :exception

  TEMPLATE = <<~ERB
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>UploadGuard workshop demo</title>
        <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
      </head>
      <body class="min-h-screen bg-zinc-100 font-sans text-zinc-950 antialiased">
        <main class="mx-auto min-h-screen max-w-3xl px-4 py-14 sm:px-6 lg:py-20">
          <header>
            <h1 class="text-center text-balance text-4xl font-black leading-tight tracking-[-0.035em] sm:text-5xl">UploadGuard Workshop</h1>
          </header>

          <form id="upload-form" class="mt-10" action="/validate" method="post" enctype="multipart/form-data">
            <input type="hidden" name="authenticity_token" value="<%= form_authenticity_token %>">
            <label
              id="drop-zone"
              class="relative grid min-h-72 cursor-pointer place-items-center rounded-2xl border-2 border-dashed border-zinc-300 bg-white px-6 py-12 text-center shadow-sm transition-colors duration-200 hover:border-violet-500 hover:bg-violet-50 focus-within:border-violet-500 focus-within:ring-4 focus-within:ring-violet-500/20 data-[dragging=true]:border-violet-500 data-[dragging=true]:bg-violet-50 motion-reduce:transition-none"
              data-dragging="false"
            >
              <input id="upload" class="absolute inset-0 size-full cursor-pointer opacity-0" type="file" name="upload" required>
              <span class="pointer-events-none grid justify-items-center">
                <span class="grid size-14 place-items-center rounded-full bg-violet-100 text-3xl text-violet-700" aria-hidden="true">↓</span>
                <strong id="drop-title" class="mt-5 text-xl">Drop a file here</strong>
                <span class="mt-2 text-zinc-600">or click to choose one</span>
                <span class="mt-6 text-sm text-zinc-500">Any file type · nothing will be stored</span>
              </span>
            </label>
          </form>

          <% if @validation %>
            <section class="mt-10" aria-live="polite">
              <% if @validation[:error] %>
                <p class="rounded-xl bg-red-50 p-5 font-semibold text-red-800"><%= @validation.fetch(:error) %></p>
              <% else %>
                <% result = @validation.fetch(:result) %>
                <% upload = @validation.fetch(:upload) %>
                <div class="flex flex-wrap items-baseline justify-between gap-3 border-b border-zinc-200 pb-5">
                  <h2 class="text-3xl font-black <%= result.accepted? ? "text-emerald-700" : "text-red-700" %>"><%= result.accepted? ? "Accepted" : "Rejected" %></h2>
                  <p class="text-sm text-zinc-500">Validated, not stored</p>
                </div>

                <dl class="mt-6 grid grid-cols-1 gap-4 text-sm sm:grid-cols-[max-content_minmax(0,1fr)] sm:gap-x-8">
                  <dt class="font-semibold text-zinc-500">Filename</dt><dd class="min-w-0 break-words font-mono"><%= upload.fetch(:filename) %></dd>
                  <dt class="font-semibold text-zinc-500">Reported MIME type</dt><dd class="min-w-0 break-words font-mono"><%= upload.fetch(:content_type) %></dd>
                  <dt class="font-semibold text-zinc-500">Size</dt><dd><%= upload.fetch(:size) %> bytes</dd>
                  <dt class="font-semibold text-zinc-500">Normalized filename</dt><dd class="min-w-0 break-words font-mono"><%= result.filename %></dd>
                  <dt class="font-semibold text-zinc-500">Computed storage path</dt><dd class="min-w-0 break-words font-mono"><%= @validation.fetch(:storage_path) %></dd>
                </dl>

                <% if result.errors.any? %>
                  <ul class="mt-6 list-disc space-y-1 pl-5 text-red-700">
                    <% result.errors.each do |message| %><li><%= message %></li><% end %>
                  </ul>
                <% end %>

                <div class="mt-8">
                  <h3 class="text-sm font-semibold text-zinc-600">The controller used</h3>
                  <pre class="mt-3 overflow-x-auto rounded-xl bg-zinc-950 p-5 text-sm leading-7 text-zinc-100"><code>upload = params[:upload]&#10;guard = <%= @validation.fetch(:guard_call) %>&#10;result = guard.validate(upload)</code></pre>
                </div>
              <% end %>
            </section>
          <% end %>
        </main>

        <script>
          const form = document.querySelector("#upload-form");
          const input = document.querySelector("#upload");
          const dropZone = document.querySelector("#drop-zone");
          const dropTitle = document.querySelector("#drop-title");

          function submitFile() {
            if (!input.files.length) return;

            dropTitle.textContent = `Validating ${input.files[0].name}…`;
            form.requestSubmit();
          }

          ["dragenter", "dragover"].forEach((eventName) => {
            dropZone.addEventListener(eventName, (event) => {
              event.preventDefault();
              dropZone.dataset.dragging = "true";
            });
          });

          ["dragleave", "drop"].forEach((eventName) => {
            dropZone.addEventListener(eventName, (event) => {
              event.preventDefault();
              dropZone.dataset.dragging = "false";
            });
          });

          dropZone.addEventListener("drop", (event) => {
            input.files = event.dataTransfer.files;
            submitFile();
          });

          input.addEventListener("change", submitFile);
        </script>
      </body>
    </html>
  ERB

  def show
    render inline: TEMPLATE, layout: false
  end

  def validate
    @validation = validation_for(params[:upload])
    render inline: TEMPLATE, layout: false
  end

  private

  def validation_for(upload)
    return { error: "Choose a file to validate." } unless upload.respond_to?(:original_filename)

    guard, guard_call = guard_for(upload)
    result = guard.validate(upload)
    {
      guard_call: guard_call,
      result: result,
      storage_path: guard.storage_path("/srv/uploads", upload),
      upload: upload_details(upload)
    }
  end

  def guard_for(upload)
    if upload.content_type.to_s == "application/pdf"
      [UploadGuard::Guard.invoice_pdf, "UploadGuard::Guard.invoice_pdf"]
    else
      [UploadGuard::Guard.logo, "UploadGuard::Guard.logo"]
    end
  end

  def upload_details(upload)
    {
      filename: upload.original_filename,
      content_type: upload.content_type,
      size: upload.size
    }
  end
end
# rubocop:enable Metrics/ClassLength, Style/OneClassPerFile

UploadGuardDemo.initialize!
UploadGuardDemo.routes.draw do
  root "uploads#show"
  post "/validate", to: "uploads#validate"
  get "/favicon.ico", to: ->(_environment) { [204, {}, []] }
end

port = Integer(ENV.fetch("PORT", 3000))
puts "UploadGuard demo: http://127.0.0.1:#{port}"
Rackup::Server.start(
  app: UploadGuardDemo,
  server: "puma",
  Host: "127.0.0.1",
  Port: port
)
