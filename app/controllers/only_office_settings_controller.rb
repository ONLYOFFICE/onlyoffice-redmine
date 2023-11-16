#
# (c) Copyright Ascensio System SIA 2023
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

class OnlyOfficeSettingsController < ApplicationController
  extend T::Sig

  # ```http
  # GET /settings/plugin/onlyoffice_redmine HTTP/1.1
  # Accept: text/html
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  sig { params(helpers: T.untyped).returns(String) }
  def self.index(helpers)
    settings = OnlyOfficeRedmine::Settings.current

    view = Views::Settings::Plugin.new(helpers:)
    view.setup_assets

    view.action = helpers.onlyoffice_update_settings_url

    view.document_server_url.name = "onlyoffice[document_server_url]"
    view.document_server_url.placeholder = "http://document-server/"
    view.document_server_url.value = settings.document_server.url

    view.document_server_internal_url.name = "onlyoffice[document_server_internal_url]"
    view.document_server_internal_url.placeholder = "http://document-server/"
    view.document_server_internal_url.value = settings.document_server.internal_url

    view.plugin_internal_url.name = "onlyoffice[plugin_internal_url]"
    view.plugin_internal_url.placeholder = "http://redmine/"
    view.plugin_internal_url.value = settings.plugin.internal_url

    view.trial_enabled.name = "onlyoffice[trial_enabled]"
    view.trial_enabled.value = "1"
    view.trial_enabled.checked = settings.trial.enabled

    view.jwt_secret.name = "onlyoffice[jwt_secret]"
    view.jwt_secret.value = settings.jwt.secret

    view.jwt_http_header.name = "onlyoffice[jwt_http_header]"
    view.jwt_http_header.value = settings.jwt.http_header

    view.ssl_verification_disabled.name = "onlyoffice[ssl_verification_disabled]"
    view.ssl_verification_disabled.value = "1"
    view.ssl_verification_disabled.checked = settings.ssl.verification_disabled

    view.editor_chat_enabled.name = "onlyoffice[editor_chat_enabled]"
    view.editor_chat_enabled.value = "1"
    view.editor_chat_enabled.checked = settings.editor.chat_enabled

    view.editor_compact_header_enabled.name = "onlyoffice[editor_compact_header_enabled]"
    view.editor_compact_header_enabled.value = "1"
    view.editor_compact_header_enabled.checked = settings.editor.compact_header_enabled

    view.editor_feedback_enabled.name = "onlyoffice[editor_feedback_enabled]"
    view.editor_feedback_enabled.value = "1"
    view.editor_feedback_enabled.checked = settings.editor.feedback_enabled

    view.editor_help_enabled.name = "onlyoffice[editor_help_enabled]"
    view.editor_help_enabled.value = "1"
    view.editor_help_enabled.checked = settings.editor.help_enabled

    view.editor_toolbar_tabs_disabled.name = "onlyoffice[editor_toolbar_tabs_disabled]"
    view.editor_toolbar_tabs_disabled.value = "1"
    view.editor_toolbar_tabs_disabled.checked = settings.editor.toolbar_tabs_disabled

    view.inline
  end

  include OnlyOfficePluginHelper::Regular
  include OnlyOfficeJWTHelper
  include OnlyOfficeSettingsHelper

  before_action     :require_admin
  require_sudo_mode :update

  before_action :require_onlyoffice_plugin
  rescue_from   OnlyOfficeRedmine::SettingsError, with: :handle_settings_error

  class UpdatePayload < T::Struct
    prop :editor_chat_enabled,           String,           default: "0"
    prop :editor_compact_header_enabled, String,           default: "0"
    prop :editor_feedback_enabled,       String,           default: "0"
    prop :editor_help_enabled,           String,           default: "0"
    prop :editor_toolbar_tabs_disabled,  String,           default: "0"
    prop :ssl_verification_disabled,     String,           default: "0"
    prop :jwt_secret,                    T.nilable(String)
    prop :jwt_http_header,               T.nilable(String)
    prop :document_server_url,           T.nilable(String)
    prop :document_server_internal_url,  T.nilable(String)
    prop :plugin_internal_url,           T.nilable(String)
    prop :trial_enabled,                 String,           default: "0"
  end

  # ```http
  # PATCH /onlyoffice/settings HTTP/1.1
  # Accept: text/html
  # Content-Type: application/x-www-form-urlencoded; charset=utf-8
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  def update
    # TODO: find a way to keep user's choices in case of an error occurs.

    raw_payload = params["onlyoffice"].permit!.to_h
    payload = UpdatePayload.from_hash(raw_payload)

    settings = OnlyOfficeRedmine::Settings.current
    patch = payload.to_settings(settings)
    patch.plugin.url = helpers.home_url

    patch.save do |conversion|
      conversion.filetype = "txt"
      conversion.key = Time.now.to_i.to_s
      conversion.outputtype = "docx"
      conversion.url = helpers.onlyoffice_ping_url
      conversion
    end

    flash[:notice] = I18n.t("notice_successful_update")
    redirect_to_plugin_settings
  end

  class UpdatePayload
    extend T::Sig

    sig { params(hash: T.untyped, strict: T.untyped).returns(UpdatePayload) }
    def self.from_hash(hash, strict = nil)
      super(hash, strict)
    end

    sig do
      params(settings: OnlyOfficeRedmine::Settings)
        .returns(OnlyOfficeRedmine::Settings)
    end
    def to_settings(settings)
      a = settings.serialize
      b = to_raw_config
      c = a.deep_merge(b)
      OnlyOfficeRedmine::Settings.from_hash(c)
    end

    sig { returns(T.untyped) }
    private def to_raw_config
      hash = {}

      hash["editor"] =
        begin
          h = {}
          h["chat_enabled"]           = OnlyOffice::STDLIB::String.to_b(editor_chat_enabled)
          h["compact_header_enabled"] = OnlyOffice::STDLIB::String.to_b(editor_compact_header_enabled)
          h["feedback_enabled"]       = OnlyOffice::STDLIB::String.to_b(editor_feedback_enabled)
          h["help_enabled"]           = OnlyOffice::STDLIB::String.to_b(editor_help_enabled)
          h["toolbar_tabs_disabled"]  = OnlyOffice::STDLIB::String.to_b(editor_toolbar_tabs_disabled)
          h
        end

      hash["ssl"] =
        begin
          h = {}

          ssl_verification_disabled = OnlyOffice::STDLIB::String.to_b(self.ssl_verification_disabled)
          h["verify_mode"] =
            if ssl_verification_disabled
              OpenSSL::SSL::VERIFY_NONE
            else
              OpenSSL::SSL::VERIFY_PEER
            end

          h
        end

      hash["jwt"] =
        begin
          h = {}

          jwt_secret = self.jwt_secret
          if jwt_secret
            h["secret"] = jwt_secret
            h["enabled"] = jwt_secret != ""
          else
            h["enabled"] = true
          end

          jwt_http_header = self.jwt_http_header
          if jwt_http_header
            h["http_header"] = jwt_http_header
          end

          h
        end

      hash["document_server"] =
        begin
          h = {}

          document_server_url = self.document_server_url
          if document_server_url
            h["url"] = document_server_url
          end

          document_server_internal_url = self.document_server_internal_url
          if document_server_internal_url
            h["internal_url"] = document_server_internal_url
          end

          h
        end

      hash["plugin"] =
        begin
          h = {}

          plugin_internal_url = self.plugin_internal_url
          if plugin_internal_url
            h["internal_url"] = plugin_internal_url
          end

          h["enabled"] = hash["document_server"]["url"] != ""
          h
        end

      hash["trial"] =
        begin
          h = {}
          h["enabled"] = OnlyOffice::STDLIB::String.to_b(trial_enabled)
          h
        end

      hash
    end
  end
end
