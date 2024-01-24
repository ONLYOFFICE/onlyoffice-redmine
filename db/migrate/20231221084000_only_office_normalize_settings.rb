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

class OnlyOfficeNormalizeSettings < ActiveRecord::Migration[5.2]
  def change
    defaults = OnlyOfficeRedmine::InternalSettings.defaults
    raw = OnlyOfficeRedmine::Settings.read
    internal = OnlyOfficeRedmine::InternalSettings.from_hash(raw)

    unless raw["conversion_timeout"]
      internal.conversion_timeout            = defaults.conversion_timeout
    end
    unless raw["editor_chat"]
      internal.editor_chat_enabled           = defaults.editor_chat_enabled
    end
    unless raw["editor_compact_header"]
      internal.editor_compact_header_enabled = defaults.editor_compact_header_enabled
    end
    unless raw["editor_feedback"]
      internal.editor_feedback_enabled       = defaults.editor_feedback_enabled
    end
    unless raw["forcesave"]
      internal.editor_force_save_enabled     = defaults.editor_force_save_enabled
    end
    unless raw["editor_help"]
      internal.editor_help_enabled           = defaults.editor_help_enabled
    end
    unless raw["editor_toolbar_no_tabs"]
      internal.editor_toolbar_tabs_disabled  = defaults.editor_toolbar_tabs_disabled
    end
    unless raw["formats_editable"]
      internal.formats_editable              = defaults.formats_editable
    end
    unless raw["check_cert"]
      internal.ssl_verification_disabled     = defaults.ssl_verification_disabled
    end
    unless raw["jwtsecret"]
      internal.jwt_secret                    = defaults.jwt_secret
    end
    unless raw["jwt_algorithm"]
      internal.jwt_algorithm                 = defaults.jwt_algorithm
    end
    unless raw["jwtheader"]
      internal.jwt_http_header               = defaults.jwt_http_header
    end
    unless raw["onlyoffice_key"]
      internal.fallback_jwt_secret           = defaults.fallback_jwt_secret
    end
    unless raw["fallback_jwt_algorithm"]
      internal.fallback_jwt_algorithm        = defaults.fallback_jwt_algorithm
    end
    unless raw["oo_address"]
      internal.document_server_url           = defaults.document_server_url
    end
    unless raw["inner_editor"]
      internal.document_server_internal_url  = defaults.document_server_internal_url
    end
    unless raw["inner_server"]
      internal.plugin_internal_url           = defaults.plugin_internal_url
    end
    unless raw["editor_demo"]
      internal.trial_enabled                 = defaults.trial_enabled
    end
    unless raw["demo_date_start"]
      internal.trial_enabled_at              = defaults.trial_enabled_at
    end

    settings = internal.to_settings
    settings = settings.normalize
    settings.force_save
  end
end
