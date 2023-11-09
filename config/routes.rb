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

# rubocop:disable Layout/LineLength

# Attachments
get  "onlyoffice/containers/:container_type/:container_id/attachments/new", to: "only_office_attachments#new",         as: "onlyoffice_new_attachment"
post "onlyoffice/containers/:container_type/:container_id/attachments/new", to: "only_office_attachments#create",      as: "onlyoffice_create_attachment"
get  "onlyoffice/attachments/:attachment_id/view",                          to: "only_office_attachments#view",        as: "onlyoffice_view_attachment"
get  "onlyoffice/attachments/:attachment_id/edit",                          to: "only_office_attachments#edit",        as: "onlyoffice_edit_attachment"
get  "onlyoffice/attachments/:attachment_id/download",                      to: "only_office_attachments#download",    as: "onlyoffice_raw_download_attachment"
get  "onlyoffice/attachments/:attachment_id/convert",                       to: "only_office_attachments#convert",     as: "onlyoffice_convert_attachment"
post "onlyoffice/attachments/:attachment_id/save-as",                       to: "only_office_attachments#save_as",     as: "onlyoffice_save_as_attachment"
post "onlyoffice/attachments/:attachment_id/download-as",                   to: "only_office_attachments#download_as", as: "onlyoffice_download_as_attachment"
post "onlyoffice/attachments/:attachment_id/callback",                      to: "only_office_attachments#callback",    as: "onlyoffice_raw_callback_attachment"

# Ping
get  "onlyoffice/ping", to: "only_office_ping#index", as: "onlyoffice_ping"

# Settigns
post "onlyoffice/settings", to: "only_office_settings#update", as: "onlyoffice_update_settings"

# rubocop:enable Layout/LineLength
