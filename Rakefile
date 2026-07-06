# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

Rake::Task[:release].clear if Rake::Task.task_defined?(:release)
task :release do
  abort "upload_guard_workshop is a RubyConf workshop lab gem and must not be released."
end

task default: %i[test rubocop]
