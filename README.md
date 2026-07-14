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

## Stuck? Use the Dev Container

If local setup fails, use the repository's dev container as a fallback environment. You need either VS Code with the Dev Containers extension and Docker Desktop, or GitHub Codespaces — no local Ruby required.

1. Open the repository in VS Code and choose **Reopen in Container** (or create a Codespace on GitHub).
2. Wait for the first boot to finish — the container runs `bin/setup` and `bin/doctor` automatically.
3. Look for the message `Your environment is ready.` in the setup output, then continue with `bundle exec rake`.

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

For an interactive, single-file Rails prototype, run:

```sh
bundle exec rake server
```

The first run installs the example's Rails and Puma dependencies. Then open
`http://127.0.0.1:3000` and drag in a file. The prototype validates it in memory,
shows the result and the controller's UploadGuard call, and never stores the
file. It loads Tailwind CSS from its development-only Play CDN, so its styling
requires an internet connection.

## Workshop Feedback

Please [share your feedback about the workshop](https://forms.gle/o4QhkGdpx5wkcXat5).

<details>
<summary><strong>Intentional Vulnerabilities</strong></summary>

These behaviors are intentional workshop material:

- The guard trusts caller-supplied `content_type` metadata instead of inspecting bytes.
- Extension validation uses weak substring matching, so names like `invoice.pdf.exe` are accepted.
- `safe_filename` preserves path segments from `original_filename`.
- `storage_path` joins the preserved filename to the destination directory, allowing path traversal-shaped output.

Tests document these behaviors so attendees can see the baseline before fixing anything.

</details>
