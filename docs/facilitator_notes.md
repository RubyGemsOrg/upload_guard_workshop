# Facilitator Notes

These notes describe the intended vulnerable baseline for the RubyConf 2026 lab. Keep them facilitator-facing unless the exercise asks attendees to inspect the answer key.

## Intended Findings

| Finding | Severity for lab | Location | Teaching goal |
| --- | --- | --- | --- |
| Trusts upload metadata | High | `UploadGuard::Guard#content_type_allowed?` | Scanners and reviewers should notice that `content_type` comes from the request object, not from file inspection. |
| Weak extension validation | Medium | `UploadGuard::Guard#extension_allowed?` | `invoice.pdf.exe` passes because the check uses substring matching instead of a strict final extension comparison. |
| Unsafe filename handling | High | `UploadGuard::Guard#safe_filename` | The method strips null bytes and whitespace but leaves `../` path segments intact. |
| Path traversal-shaped storage path | High | `UploadGuard::Guard#storage_path` | Joining a base directory with attacker-controlled path segments creates an unsafe destination path. |

## Suggested Report Handling Exercise

1. Triage whether each report is exploitable in the host application.
2. Separate library responsibility from application responsibility.
3. Write tests for the secure behavior before changing the implementation.
4. Patch the smallest public API surface first.
5. Re-run `bundle exec rake` and summarize the change for maintainers.

## Expected Baseline Commands

```sh
bundle exec rake test
bundle exec rubocop
gem build upload_guard_workshop.gemspec
```

The release command should fail:

```sh
bundle exec rake release
```

Expected failure text includes `must not be released`.

## Fixture Map

- `company-logo.png`: normal company logo scenario.
- `company-logo.gif`: disallowed image MIME scenario.
- `invoice-1001.pdf`: normal invoice PDF scenario.
- `not-really-a-logo.png`: plain text fixture accepted when metadata says `image/png`.
- `invoice.pdf.exe`: executable-looking filename accepted when metadata says `application/pdf`.
