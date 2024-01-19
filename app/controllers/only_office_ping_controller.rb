#
# (c) Copyright Ascensio System SIA 2024
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

# typed: true
# frozen_string_literal: true

class OnlyOfficePingController < ApplicationController
  include OnlyOfficePluginHelper::Regular
  include OnlyOfficeSettingsHelper
  include OnlyOfficeJWTHelper

  before_action      :require_onlyoffice_plugin
  before_action      :check_trial
  skip_before_action :verify_authenticity_token
  before_action      :verify_jwt_token

  rescue_from OnlyOfficeRedmine::SettingsError, with: :handle_settings_error

  # ```http
  # GET /onlyoffice/ping?token={{fallback_jwt_token}} HTTP/1.1
  # Accept: text/plain
  # Host: {{plugin_internal_url}}
  # {{jwt_header}}: Bearer {{jwt_token}}
  # ```
  def index
    send_data(
      "pong",
      filename: "pong.txt",
      type: "text/plain",
      disposition: "attachment"
    )
  end
end
