# frozen_string_literal: true

require_relative "lib/upload_guard_workshop/version"

Gem::Specification.new do |spec|
  spec.name = "upload_guard_workshop"
  spec.version = UploadGuard::VERSION
  spec.authors = ["Colby Swandale"]
  spec.email = ["colby@rubygems.org"]

  spec.summary = "Workshop-only upload validation gem with intentional vulnerabilities."
  spec.description = "A deliberately insecure RubyConf 2026 workshop gem for practicing scan, triage, " \
                     "and fix workflows."
  spec.homepage = "https://example.invalid/upload_guard_workshop"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["allowed_push_host"] = "https://example.invalid"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://example.invalid/upload_guard_workshop"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir[
    "LICENSE.txt",
    "README.md",
    "docs/**/*.md",
    "examples/**/*.rb",
    "lib/**/*.rb",
    "sig/**/*.rbs"
  ]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://guides.rubygems.org/make-your-own-gem/
end
