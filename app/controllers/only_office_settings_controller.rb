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

    view = Views::Settings::Plugin.new(helpers: helpers)
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

    formats = OnlyOffice::Resources::Formats.read

    view.formats_editable.options = formats.lossy_editable.sort_by(&:name).map do |format|
      selected = settings.formats.editable.include?(format.name)
      Views::Option.new(
        label: format.name,
        name: "onlyoffice[formats_editable][]",
        value: format.name,
        selected: selected
      )
    end

    OnlyOffice::Resources::Formats.unread

    view.inline
  end

  include OnlyOfficePluginHelper::Regular
  include OnlyOfficeJWTHelper
  include OnlyOfficeSettingsHelper

  before_action     :require_admin
  require_sudo_mode :update
  before_action     :require_onlyoffice_plugin_to_be_exist

  class UpdatePayload < T::Struct
    prop :editor_chat_enabled,           String,           default: "0"
    prop :editor_compact_header_enabled, String,           default: "0"
    prop :editor_feedback_enabled,       String,           default: "0"
    prop :editor_help_enabled,           String,           default: "0"
    prop :editor_toolbar_tabs_disabled,  String,           default: "0"
    prop :formats_editable,              T::Array[String], default: []
    prop :ssl_verification_disabled,     String,           default: "0"
    prop :jwt_secret,                    String,           default: ""
    prop :jwt_http_header,               String,           default: ""
    prop :document_server_url,           String,           default: ""
    prop :document_server_internal_url,  String,           default: ""
    prop :plugin_internal_url,           String,           default: ""
    prop :trial_enabled,                 String,           default: "0"
  end

  # ```http
  # POST /onlyoffice/settings HTTP/1.1
  # Accept: text/html
  # Content-Type: application/x-www-form-urlencoded; charset=utf-8
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  def update
    # TODO: find a way to keep user's choices in case of an error occurs.

    begin
      raw_payload = params["onlyoffice"].permit!.to_h
      payload = UpdatePayload.from_hash(raw_payload)

      patch = payload.to_settings
      patch.plugin.url = helpers.home_url

      patch.save do |patched, conversion|
        url = helpers.onlyoffice_ping_url
        url = patched.plugin.resolve_internal_url(url)
        if patched.fallback_jwt.enabled
          url = patched.fallback_jwt.encode_url(url)
        end
        conversion.filetype = "txt"
        conversion.key = Time.now.to_i.to_s
        conversion.outputtype = "docx"
        conversion.url = url
        conversion
      end

      flash[:notice] = I18n.t("notice_successful_update")
    rescue OnlyOfficeRedmine::SettingsError => e
      code, message =
        case e
        when OnlyOfficeRedmine::SettingsError.trial_expired
          [402, I18n.t("onlyoffice_editor_trial_period_ended")]
        when OnlyOfficeRedmine::SettingsError.validation_failed
          [422, "Internal Error"]
        else
          [500, "Internal Error"]
        end

      flash[:error] = message
      response.status = code
    rescue StandardError
      flash[:error] = "Internal Error"
      response.status = 500
    end

    redirect_to_plugin_settings
  end

  class UpdatePayload
    extend T::Sig

    sig { params(hash: T.untyped, strict: T.untyped).returns(UpdatePayload) }
    def self.from_hash(hash, strict = nil)
      super(hash, strict)
    end

    sig { returns(OnlyOfficeRedmine::Settings) }
    def to_settings
      current = OnlyOfficeRedmine::Settings.current

      general = OnlyOffice::Config.new

      general.conversion.timeout = current.conversion.timeout

      general.editor.chat_enabled           = OnlyOffice::STDLIB::String.to_b(editor_chat_enabled)
      general.editor.compact_header_enabled = OnlyOffice::STDLIB::String.to_b(editor_compact_header_enabled)
      general.editor.feedback_enabled       = OnlyOffice::STDLIB::String.to_b(editor_feedback_enabled)
      general.editor.help_enabled           = OnlyOffice::STDLIB::String.to_b(editor_help_enabled)
      general.editor.toolbar_tabs_disabled  = OnlyOffice::STDLIB::String.to_b(editor_toolbar_tabs_disabled)

      general.formats.editable = formats_editable

      ssl_verification_disabled = OnlyOffice::STDLIB::String.to_b(self.ssl_verification_disabled)
      general.ssl.verify_mode =
        if ssl_verification_disabled
          OpenSSL::SSL::VERIFY_NONE
        else
          OpenSSL::SSL::VERIFY_PEER
        end

      general.jwt.enabled = jwt_secret != ""
      general.jwt.secret = jwt_secret
      general.jwt.algorithm = current.jwt.algorithm
      general.jwt.http_header = jwt_http_header

      general.document_server.url = document_server_url
      general.document_server.internal_url = document_server_internal_url

      general.plugin.enabled = document_server_url != ""
      general.plugin.url = current.plugin.url
      general.plugin.internal_url = plugin_internal_url

      general.trial.enabled = OnlyOffice::STDLIB::String.to_b(trial_enabled)
      general.trial.enabled_at = current.trial.enabled_at
      general.trial.period = current.trial.period

      additional = OnlyOfficeRedmine::AdditionalSettings.new
      additional.fallback_jwt = current.fallback_jwt

      if general.trial.enabled
        # See the `data-disabled-for-trial` in the view.
        general.jwt.enabled = current.jwt.enabled
        general.jwt.secret = current.jwt.secret
        general.jwt.http_header = current.jwt.http_header
        general.document_server.url = current.document_server.url
        general.document_server.internal_url = current.document_server.internal_url
        general.plugin.enabled = true
        general.plugin.internal_url = current.plugin.internal_url
      end

      OnlyOfficeRedmine::Settings.new(general: general, additional: additional)
    end
  end
end
