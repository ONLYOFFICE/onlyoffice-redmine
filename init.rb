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

require 'redmine'

Redmine::Plugin.register :onlyoffice_redmine do
  name 'Redmine ONLYOFFICE integration plugin'
  author 'ONLYOFFICE'
  description 'Redmine ONLYOFFICE integration plugin allows opening files uploaded to the Issues, Files, Documents, Wiki, or News modules for viewing and co-editing.'
  version '1.1.0'
  url 'https://github.com/ONLYOFFICE/onlyoffice-redmine'
  author_url 'https://www.onlyoffice.com'


  settings default: {'oo_address' => 'http://localhost/',
                     'jwtHeader' => 'Authorization',
                     'jwtsecret' => '',
                     'editor_demo' => '',
                     'editor_chat' => 'on',
                     'editor_help' => 'on',
                     'editor_compact_header' => '',
                     'editor_toolbar_no_tabs' => '',
                     'editor_feedback' => 'on',
                     'is_trial_over' => 'true'}, partial: 'settings/onlyoffice_settings'
end
