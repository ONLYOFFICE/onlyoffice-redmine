# typed: false
# frozen_string_literal: true

require "logger"
require "minitest/test_task"
require "sorbet-runtime"
require_relative "lib/only_office_redmine"
require_relative "lib2/onlyoffice/resources"

# rubocop:disable Rails/RakeEnvironment
desc "Show a plugin version"
task :version do
  print(OnlyOfficeRedmine::VERSION)
end
# rubocop:enable Rails/RakeEnvironment

# rubocop:disable Rails/RakeEnvironment
desc "Generate the formats table in README.md"
task :readme_formats do
  head = ""
  align = ""
  viewable = ""
  editable = ""
  creatable = ""

  formats = OnlyOffice::Resources::Formats.read
  formats.all.each do |format|
    unless (
      format.viewable? ||
      format.editable? ||
      format.lossy_editable? ||
      format.creatable?
    )
      next
    end
    head +=
      if format.lossy_editable?
        "#{format.name}*|"
      else
        "#{format.name}|"
      end
    align += ":-:|"
    viewable +=
      if format.viewable?
        "+|"
      else
        "-|"
      end
    editable +=
      if format.editable? || format.fillable? || format.lossy_editable?
        "+|"
      else
        "-|"
      end
    creatable +=
      if format.creatable?
        "+|"
      else
        "-|"
      end
  end

  table =
    "| |#{head}\n" \
    "|:-|#{align}\n" \
    "|View|#{viewable}\n" \
    "|Edit|#{editable}\n" \
    "|Create|#{creatable}"

  actual = File.read("./README.md")
  modified = actual.gsub(
    /(<!-- def-formats -->)[\S\s]*?(<!-- end-formats -->)/m,
    "\\1\n#{table}\n\\2"
  )
  File.write("./README.md", modified)
end
# rubocop:enable Rails/RakeEnvironment

Minitest::TestTask.create(:test) do |task|
  task.test_globs = ["test/**/*.rb"]
end
