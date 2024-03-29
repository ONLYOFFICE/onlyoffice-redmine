#
# (c) Copyright Ascensio System SIA 2022
# http://www.onlyoffice.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# typed: false
# frozen_string_literal: true

require "redmine"
require "rubygems"
require_relative "lib2/onlyoffice"
require_relative "lib2/only_office"
require_relative "app/views/views"
require_relative "lib/only_office_redmine"
require_relative "lib/only_office_redmine/settings"

if Redmine::VERSION::MAJOR == 4
  require_relative "app/helpers/only_office_error_helper"
  require_relative "app/helpers/only_office_j_w_t_helper"
  require_relative "app/helpers/only_office_plugin_helper"
  require_relative "app/helpers/only_office_router_helper"
  require_relative "app/helpers/only_office_settings_helper"
  require_relative "app/helpers/only_office_view_helper"
end

logger = Rails.logger.dup
logger.progname = OnlyOffice.logger.progname.dup
OnlyOffice.logger = logger

logger = Rails.logger.dup
logger.progname = OnlyOfficeRedmine.logger.progname.dup
OnlyOfficeRedmine.logger = logger

def check_gem(name, version)
  Gem::Specification.find_by_name(name, version)
rescue Gem::MissingSpecVersionError
  spec = Gem::Specification.find_by_name(name)
  OnlyOfficeRedmine.logger.error("Gem '#{name}' version '#{version}' not found, found version '#{spec.version}'")
rescue Gem::MissingSpecError
  OnlyOfficeRedmine.logger.error("Gem '#{name}' version '#{version}' not found")
end

check_gem("jwt", "~> 2.7.1")
check_gem("mustache", "~> 1.1.1")
check_gem("render_parent", "~> 0.1.0")
check_gem("sorbet-runtime", "~> 0.5.10969")

Redmine::Plugin.register(OnlyOfficeRedmine::NAME.to_sym) do
  # rubocop:disable Layout/LineLength
  name        "Redmine ONLYOFFICE integration plugin"
  author      "ONLYOFFICE"
  description "Redmine ONLYOFFICE integration plugin allows opening files uploaded to the Issues, Files, Documents, Wiki, or News modules for viewing and co-editing."
  version     OnlyOfficeRedmine::VERSION
  url         "https://github.com/ONLYOFFICE/onlyoffice-redmine"
  author_url  "https://www.onlyoffice.com"
  # rubocop:enable Layout/LineLength

  settings(
    default: OnlyOfficeRedmine::InternalSettings.defaults.serialize,
    partial: "settings/onlyoffice_settings"
  )
end
