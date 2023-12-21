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
require_relative "lib2/onlyoffice"
require_relative "lib2/only_office"
require_relative "app/views/views"
require_relative "lib/only_office_redmine"
require_relative "lib/only_office_redmine/settings"

logger = Rails.logger.dup
logger.progname = OnlyOffice.logger.progname.dup
OnlyOffice.logger = logger

logger = Rails.logger.dup
logger.progname = OnlyOfficeRedmine.logger.progname.dup
OnlyOfficeRedmine.logger = logger

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
    default: OnlyOfficeRedmine::Settings.defaults.serialize,
    partial: "settings/onlyoffice_settings"
  )
end
