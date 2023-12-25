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

# [Redmine Reference: Controller](https://github.com/redmine/redmine/blob/5.0.0/app/controllers/settings_controller.rb#L64) \
# [Redmine Reference: View](https://github.com/redmine/redmine/blob/5.0.0/app/views/settings/plugin.html.erb)
class Views::Settings::Plugin < Views::Mustache
  extend T::Sig
  include Blocks::Assets
  include Blocks::Banner

  self.template_file = "#{template_path}/settings/plugin.mustache"

  sig { returns(String) }
  attr_accessor :action

  sig { returns(String) }
  attr_accessor :advanced_legend

  sig { returns(String) }
  attr_accessor :security_legend

  sig { returns(String) }
  attr_accessor :editor_legend

  sig { returns(Views::Input) }
  attr_accessor :document_server_url

  sig { returns(Views::Input) }
  attr_accessor :document_server_internal_url

  sig { returns(Views::Input) }
  attr_accessor :plugin_internal_url

  sig { returns(Views::Input) }
  attr_accessor :trial_enabled

  sig { returns(Views::Input) }
  attr_accessor :jwt_secret

  sig { returns(Views::Input) }
  attr_accessor :jwt_http_header

  sig { returns(Views::Input) }
  attr_accessor :ssl_verification_disabled

  sig { returns(Views::Input) }
  attr_accessor :editor_chat_enabled

  sig { returns(Views::Input) }
  attr_accessor :editor_compact_header_enabled

  sig { returns(Views::Input) }
  attr_accessor :editor_feedback_enabled

  sig { returns(Views::Input) }
  attr_accessor :editor_help_enabled

  sig { returns(Views::Input) }
  attr_accessor :editor_toolbar_tabs_disabled

  sig { returns(String) }
  attr_accessor :formats_legend

  sig { returns(Views::Select) }
  attr_accessor :formats_editable

  sig { override.params(helpers: T.untyped).void }
  def initialize(helpers:)
    super(helpers: helpers)

    action = ""
    @action = T.let(action, String)

    advanced_legend = I18n.t("onlyoffice_additional_settings")
    @advanced_legend = T.let(advanced_legend, String)

    security_legend = I18n.t("onlyoffice_settings_security")
    @security_legend = T.let(security_legend, String)

    editor_legend = I18n.t("onlyoffice_settings_editor_view")
    @editor_legend = T.let(editor_legend, String)

    document_server_url = Views::Input.new
    document_server_url.label = I18n.t("onlyoffice_settings_doc_url")
    document_server_url.note = I18n.t("onlyoffice_settings_doc_url_note")
    @document_server_url = T.let(document_server_url, Views::Input)

    document_server_internal_url = Views::Input.new
    document_server_internal_url.label = I18n.t("onlyoffice_additional_settings_editor")
    @document_server_internal_url = T.let(document_server_internal_url, Views::Input)

    plugin_internal_url = Views::Input.new
    plugin_internal_url.label = I18n.t("onlyoffice_additional_settings_server")
    @plugin_internal_url = T.let(plugin_internal_url, Views::Input)

    trial_enabled = Views::Input.new
    trial_enabled.label = I18n.t("onlyoffice_settings_editor_demo")
    @trial_enabled = T.let(trial_enabled, Views::Input)

    jwt_secret = Views::Input.new
    jwt_secret.label = I18n.t("onlyoffice_settings_jwtsecret")
    jwt_secret.note = I18n.t("onlyoffice_settings_jwtsecret_note")
    @jwt_secret = T.let(jwt_secret, Views::Input)

    jwt_http_header = Views::Input.new
    jwt_http_header.label = I18n.t("onlyoffice_settings_jwtheader")
    @jwt_http_header = T.let(jwt_http_header, Views::Input)

    ssl_verification_disabled = Views::Input.new
    ssl_verification_disabled.label = I18n.t("onlyoffice_settings_check_cert")
    @ssl_verification_disabled = T.let(ssl_verification_disabled, Views::Input)

    editor_chat_enabled = Views::Input.new
    editor_chat_enabled.label = I18n.t("onlyoffice_settings_editor_view_chat")
    @editor_chat_enabled = T.let(editor_chat_enabled, Views::Input)

    editor_compact_header_enabled = Views::Input.new
    editor_compact_header_enabled.label = I18n.t("onlyoffice_settings_editor_view_header")
    @editor_compact_header_enabled = T.let(editor_compact_header_enabled, Views::Input)

    editor_feedback_enabled = Views::Input.new
    editor_feedback_enabled.label = I18n.t("onlyoffice_settings_editor_view_feedback")
    @editor_feedback_enabled = T.let(editor_feedback_enabled, Views::Input)

    editor_help_enabled = Views::Input.new
    editor_help_enabled.label = I18n.t("onlyoffice_settings_editor_view_help")
    @editor_help_enabled = T.let(editor_help_enabled, Views::Input)

    editor_toolbar_tabs_disabled = Views::Input.new
    editor_toolbar_tabs_disabled.label = I18n.t("onlyoffice_settings_editor_view_toolbar")
    @editor_toolbar_tabs_disabled = T.let(editor_toolbar_tabs_disabled, Views::Input)

    formats_legend = I18n.t("onlyoffice_settings_formats_legend")
    @formats_legend = T.let(formats_legend, String)

    formats_editable = Views::Select.new
    formats_editable.label = I18n.t("onlyoffice_settings_formats_editable_note")
    @formats_editable = T.let(formats_editable, Views::Select)
  end
end
