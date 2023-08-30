# typed: false
# frozen_string_literal: true

require "logger"
require "minitest/test_task"
require "sorbet-runtime"
require_relative "lib/only_office_redmine"

# rubocop:disable Rails/RakeEnvironment
desc "Show a plugin version"
task :version do
  print(OnlyOfficeRedmine::VERSION)
end
# rubocop:enable Rails/RakeEnvironment

Minitest::TestTask.create(:test) do |task|
  task.test_globs = ["test/**/*.rb"]
end
