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

  sig { override.params(helpers: T.untyped).void }
  def initialize(helpers:)
    super(helpers:)
    @helpers = helpers
    @action = ""
    @document_server_url_label = I18n.t("onlyoffice_settings_doc_url")
    @document_server_url_note = I18n.t("onlyoffice_settings_doc_url_note")
    @document_server_url_name = ""
    @document_server_url_value = ""
    @document_server_url_placeholder = ""
    @advanced_legend = I18n.t("onlyoffice_additional_settings")
    @document_server_internal_url_label = I18n.t("onlyoffice_additional_settings_server")
    @document_server_internal_url_name = ""
    @document_server_internal_url_value = ""
    @document_server_internal_url_placeholder = ""
    @server_internal_url_label = I18n.t("onlyoffice_additional_settings_server")
    @server_internal_url_name = ""
    @server_internal_url_value = ""
    @server_internal_url_placeholder = ""
    @demo_document_server_enabled_label = I18n.t("onlyoffice_settings_editor_demo")
    @demo_document_server_enabled_name = ""
    @demo_document_server_enabled_value = ""
    @demo_document_server_enabled_checked = false
    @security_legend = I18n.t("onlyoffice_settings_security")
    @jwt_secret_label = I18n.t("onlyoffice_settings_jwtsecret")
    @jwt_secret_note = I18n.t("onlyoffice_settings_jwtsecret_note")
    @jwt_secret_name = ""
    @jwt_secret_value = ""
    @jwt_header_label = I18n.t("onlyoffice_settings_jwtheader")
    @jwt_header_name = ""
    @jwt_header_value = ""
    @ssl_verify_mode_label = I18n.t("onlyoffice_settings_check_cert")
    @ssl_verify_mode_name = ""
    @ssl_verify_mode_value = ""
    @ssl_verify_mode_checked = false
    @editor_legend = I18n.t("onlyoffice_settings_editor_view")
    @editor_chat_visible_label = I18n.t("onlyoffice_settings_editor_view_chat")
    @editor_chat_visible_name = ""
    @editor_chat_visible_value = ""
    @editor_chat_visible_checked = false
    @editor_compact_header_visible_label = I18n.t("onlyoffice_settings_editor_view_header")
    @editor_compact_header_visible_name = ""
    @editor_compact_header_visible_value = ""
    @editor_compact_header_visible_checked = false
    @editor_feedback_visible_label = I18n.t("onlyoffice_settings_editor_view_feedback")
    @editor_feedback_visible_name = ""
    @editor_feedback_visible_value = ""
    @editor_feedback_visible_checked = false
    @editor_help_visible_label = I18n.t("onlyoffice_settings_editor_view_help")
    @editor_help_visible_name = ""
    @editor_help_visible_value = ""
    @editor_help_visible_checked = false
    @editor_monochrome_toolbar_visible_label = I18n.t("onlyoffice_settings_editor_view_toolbar")
    @editor_monochrome_toolbar_visible_name = ""
    @editor_monochrome_toolbar_visible_value = ""
    @editor_monochrome_toolbar_visible_checked = false
  end

  sig { params(helpers: T.untyped, settings: T.untyped).returns(String) }
  def self.inline(helpers:, settings:)
    view = new(helpers:)
    view.setup_assets

    view.action = helpers.onlyoffice_plugin_settings_path
    view.document_server_url_name = "settings[oo_address]"
    view.document_server_url_value = settings[:oo_address]
    view.document_server_url_placeholder = "http://docserver/"
    view.document_server_internal_url_name = "settings[inner_editor]"
    view.document_server_internal_url_value = settings[:inner_editor]
    view.document_server_internal_url_placeholder = "http://docserver/"
    view.server_internal_url_name = "settings[inner_server]"
    view.server_internal_url_value = settings[:inner_server]
    view.server_internal_url_placeholder = "http://redmine/"
    view.demo_document_server_enabled_name = "settings[editor_demo]"
    view.demo_document_server_enabled_value = "on"
    view.demo_document_server_enabled_checked = settings[:editor_demo].eql?(view.demo_document_server_enabled_value)
    view.jwt_secret_name = "settings[jwtsecret]"
    view.jwt_secret_value = settings[:jwtsecret]
    view.jwt_header_name = "settings[jwtheader]"
    view.jwt_header_value = settings[:jwtheader]
    view.ssl_verify_mode_name = "settings[check_cert]"
    view.ssl_verify_mode_value = "on"
    view.ssl_verify_mode_checked = settings[:check_cert].eql?(view.ssl_verify_mode_value)
    view.editor_chat_visible_name = "settings[editor_chat]"
    view.editor_chat_visible_value = "on"
    view.editor_chat_visible_checked = settings[:editor_chat].eql?(view.editor_chat_visible_value)
    view.editor_compact_header_visible_name = "settings[editor_compact_header]"
    view.editor_compact_header_visible_value = "on"
    view.editor_compact_header_visible_checked = settings[:editor_compact_header].eql?(view.editor_compact_header_visible_value)
    view.editor_feedback_visible_name = "settings[editor_feedback]"
    view.editor_feedback_visible_value = "on"
    view.editor_feedback_visible_checked = settings[:editor_feedback].eql?(view.editor_feedback_visible_value)
    view.editor_help_visible_name = "settings[editor_help]"
    view.editor_help_visible_value = "on"
    view.editor_help_visible_checked = settings[:editor_help].eql?(view.editor_help_visible_value)
    view.editor_monochrome_toolbar_visible_name = "settings[editor_toolbar_no_tabs]"
    view.editor_monochrome_toolbar_visible_value = "on"
    view.editor_monochrome_toolbar_visible_checked = settings[:editor_toolbar_no_tabs].eql?(view.editor_monochrome_toolbar_visible_value)

    view.render.html_safe
  end

  # Action

  sig { returns(String) }
  attr_accessor :action

  # Main

  sig { returns(String) }
  attr_accessor :document_server_url_label

  sig { returns(String) }
  attr_accessor :document_server_url_note

  sig { returns(String) }
  attr_accessor :document_server_url_name

  sig { returns(String) }
  attr_accessor :document_server_url_value

  sig { returns(String) }
  attr_accessor :document_server_url_placeholder

  # Advanced

  sig { returns(String) }
  attr_accessor :advanced_legend

  sig { returns(String) }
  attr_accessor :document_server_internal_url_label

  sig { returns(String) }
  attr_accessor :document_server_internal_url_name

  sig { returns(String) }
  attr_accessor :document_server_internal_url_value

  sig { returns(String) }
  attr_accessor :document_server_internal_url_placeholder

  sig { returns(String) }
  attr_accessor :server_internal_url_label

  sig { returns(String) }
  attr_accessor :server_internal_url_name

  sig { returns(String) }
  attr_accessor :server_internal_url_value

  sig { returns(String) }
  attr_accessor :server_internal_url_placeholder

  sig { returns(String) }
  attr_accessor :demo_document_server_enabled_label

  sig { returns(String) }
  attr_accessor :demo_document_server_enabled_name

  sig { returns(String) }
  attr_accessor :demo_document_server_enabled_value

  sig { returns(T::Boolean) }
  attr_accessor :demo_document_server_enabled_checked

  # Security

  sig { returns(String) }
  attr_accessor :security_legend

  sig { returns(String) }
  attr_accessor :jwt_secret_label

  sig { returns(String) }
  attr_accessor :jwt_secret_note

  sig { returns(String) }
  attr_accessor :jwt_secret_name

  sig { returns(String) }
  attr_accessor :jwt_secret_value

  sig { returns(String) }
  attr_accessor :jwt_header_label

  sig { returns(String) }
  attr_accessor :jwt_header_name

  sig { returns(String) }
  attr_accessor :jwt_header_value

  sig { returns(String) }
  attr_accessor :ssl_verify_mode_label

  sig { returns(String) }
  attr_accessor :ssl_verify_mode_name

  sig { returns(String) }
  attr_accessor :ssl_verify_mode_value

  sig { returns(T::Boolean) }
  attr_accessor :ssl_verify_mode_checked

  # Editor

  sig { returns(String) }
  attr_accessor :editor_legend

  sig { returns(String) }
  attr_accessor :editor_chat_visible_label

  sig { returns(String) }
  attr_accessor :editor_chat_visible_name

  sig { returns(String) }
  attr_accessor :editor_chat_visible_value

  sig { returns(T::Boolean) }
  attr_accessor :editor_chat_visible_checked

  sig { returns(String) }
  attr_accessor :editor_compact_header_visible_label

  sig { returns(String) }
  attr_accessor :editor_compact_header_visible_name

  sig { returns(String) }
  attr_accessor :editor_compact_header_visible_value

  sig { returns(T::Boolean) }
  attr_accessor :editor_compact_header_visible_checked

  sig { returns(String) }
  attr_accessor :editor_feedback_visible_label

  sig { returns(String) }
  attr_accessor :editor_feedback_visible_name

  sig { returns(String) }
  attr_accessor :editor_feedback_visible_value

  sig { returns(T::Boolean) }
  attr_accessor :editor_feedback_visible_checked

  sig { returns(String) }
  attr_accessor :editor_help_visible_label

  sig { returns(String) }
  attr_accessor :editor_help_visible_name

  sig { returns(String) }
  attr_accessor :editor_help_visible_value

  sig { returns(T::Boolean) }
  attr_accessor :editor_help_visible_checked

  sig { returns(String) }
  attr_accessor :editor_monochrome_toolbar_visible_label

  sig { returns(String) }
  attr_accessor :editor_monochrome_toolbar_visible_name

  sig { returns(String) }
  attr_accessor :editor_monochrome_toolbar_visible_value

  sig { returns(T::Boolean) }
  attr_accessor :editor_monochrome_toolbar_visible_checked
end
