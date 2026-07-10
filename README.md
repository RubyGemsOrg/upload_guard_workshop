# UploadGuard Workshop

`upload_guard_workshop` is a deliberately insecure Ruby gem for the RubyConf 2026 workshop **From Scan to Fix: A Maintainer's Guide to Gem Security**.

The gem models a small upload-validation library that a Rails SaaS might use before storing company logos or invoice PDFs. It is realistic enough to scan, triage, test, and patch, but it is workshop-only and intentionally unsafe for production.

## Workshop Safety Notice

This repository is for local training only.

- Do not use this gem in a real application.
- Do not publish this gem to RubyGems.org or any normal gem server.
- Do not add release workflows, trusted publishing, or RubyGems API key setup.
- Keep the intentionally vulnerable behavior intact until the workshop exercise asks you to fix it.

The gemspec uses `allowed_push_host` with `https://example.invalid`, and the release rake task aborts with a workshop warning.

## Local Setup

Clone the repository, then check whether your active environment is ready:

```sh
./bin/doctor
```

The doctor is read-only. It checks the active Ruby against the gem's supported
version, verifies Bundler and the installed dependencies, and confirms that the
library loads. It reports all useful problems in one run without installing or
changing anything.

If dependencies are missing, install them and rerun the doctor:

```sh
bundle install
./bin/doctor
```

Once the doctor reports that the environment is ready, run:

```sh
bundle exec rake
```

The default rake task runs the test suite and RuboCop. Core workshop setup should not require network access after dependencies are installed.

To try the gem from a local checkout in another app:

```ruby
gem "upload_guard_workshop", path: "../upload_guard_workshop"
```

## Example Usage

```ruby
logo_guard = UploadGuard::Guard.logo
invoice_guard = UploadGuard::Guard.invoice_pdf

logo_result = logo_guard.validate(params[:company][:logo])
invoice_result = invoice_guard.validate(params[:invoice][:pdf])

if logo_result.accepted?
  storage_path = logo_guard.storage_path(Rails.root.join("tmp/uploads"), params[:company][:logo])
  # Store or enqueue the upload in the host application.
else
  Rails.logger.warn("Logo rejected: #{logo_result.errors.join(", ")}")
end
```

See `examples/rails_controller.rb` for a Rails-flavored controller sketch.

## Public API

`UploadGuard::Guard.new` accepts:

- `allowed_mime_types`: MIME types that upload metadata may claim.
- `allowed_extensions`: filename extensions that are expected.
- `max_size`: maximum file size in bytes.

Convenience constructors:

- `UploadGuard::Guard.logo`
- `UploadGuard::Guard.invoice_pdf`

Useful methods:

- `accepted?(upload)`
- `validate(upload)`
- `safe_filename(upload)`
- `storage_path(base_dir, upload)`
- `image?(upload)`
- `document?(upload)`

An upload object is expected to respond to `original_filename`, `content_type`, and `size`, matching the shape of common Rails upload objects.

## Intentional Vulnerabilities

These behaviors are intentional workshop material:

- The guard trusts caller-supplied `content_type` metadata instead of inspecting bytes.
- Extension validation uses weak substring matching, so names like `invoice.pdf.exe` are accepted.
- `safe_filename` preserves path segments from `original_filename`.
- `storage_path` joins the preserved filename to the destination directory, allowing path traversal-shaped output.

Tests document these behaviors so attendees can see the baseline before fixing anything.

## Maintainer Workflow Practice

Suggested workshop loop:

1. Read a vulnerability report or scanner result.
2. Reproduce the behavior with the fixture files in `test/fixtures/files`.
3. Decide whether the finding is a true positive, false positive, or nuanced risk.
4. Add or update tests that express the desired secure behavior.
5. Patch the implementation.
6. Run `bundle exec rake` and explain the impact.

Facilitators can use `docs/facilitator_notes.md` for the intended findings and discussion prompts.
