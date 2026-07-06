# frozen_string_literal: true

require "open3"
require "test_helper"

class TestPublicationSafeguards < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  GEMSPEC = Gem::Specification.load(File.join(ROOT, "upload_guard_workshop.gemspec"))

  def test_gem_pushes_are_restricted_to_non_publishable_host
    assert_equal "https://example.invalid", GEMSPEC.metadata["allowed_push_host"]
  end

  def test_release_task_aborts_with_workshop_warning
    _stdout, stderr, status = Open3.capture3("bundle", "exec", "rake", "release", chdir: ROOT)

    refute status.success?
    assert_includes stderr, "must not be released"
  end

  def test_no_release_or_publish_workflows_exist
    workflows = Dir[File.join(ROOT, ".github", "workflows", "*")]

    workflows.each do |workflow|
      contents = File.read(workflow)

      refute_match(/\bgem\s+push\b/, contents, "#{workflow} must not push gems")
      refute_match(/\btrusted[-_]publishing\b/i, contents, "#{workflow} must not configure trusted publishing")
      refute_match(/\bRUBYGEMS_API_KEY\b/, contents, "#{workflow} must not reference RubyGems API keys")
    end
  end

  def test_documentation_does_not_recommend_rubygems_installation
    readme = File.read(File.join(ROOT, "README.md"))

    refute_match(/bundle add upload_guard_workshop/, readme)
    refute_match(/gem install upload_guard_workshop/, readme)
  end
end
