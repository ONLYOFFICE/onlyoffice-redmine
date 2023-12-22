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

module OnlyOfficeRedmine
  GeneralSettings = T.type_alias do
    OnlyOffice::Config
  end

  class AdditionalSettings < T::Struct
    prop :fallback_jwt, OnlyOffice::Config::JWT, default: OnlyOffice::Config::JWT.new
  end

  class InternalSettings < T::Struct
    prop :conversion_timeout,            String,           default: ""
    prop :editor_chat_enabled,           String,           default: "", name: "editor_chat"
    prop :editor_compact_header_enabled, String,           default: "", name: "editor_compact_header"
    prop :editor_feedback_enabled,       String,           default: "", name: "editor_feedback"
    prop :editor_force_save_enabled,     String,           default: "", name: "forcesave"
    prop :editor_help_enabled,           String,           default: "", name: "editor_help"
    prop :editor_toolbar_tabs_disabled,  String,           default: "", name: "editor_toolbar_no_tabs"
    prop :formats_editable,              T::Array[String], default: []
    prop :ssl_verification_disabled,     String,           default: "", name: "check_cert"
    prop :jwt_secret,                    String,           default: "", name: "jwtsecret"
    prop :jwt_algorithm,                 String,           default: ""
    prop :jwt_http_header,               String,           default: "", name: "jwtheader"
    prop :fallback_jwt_secret,           String,           default: "", name: "onlyoffice_key"
    prop :fallback_jwt_algorithm,        String,           default: ""
    prop :document_server_url,           String,           default: "", name: "oo_address"
    prop :document_server_internal_url,  String,           default: "", name: "inner_editor"
    prop :plugin_internal_url,           String,           default: "", name: "inner_server"
    prop :trial_enabled,                 String,           default: "", name: "editor_demo"
    prop :trial_enabled_at,              String,           default: "", name: "demo_date_start"
  end

  class Settings
    extend T::Sig

    NAME = "plugin_#{OnlyOfficeRedmine::NAME}".freeze

    sig { returns(Settings) }
    def self.current
      raw = ::Setting.send(NAME)
      internal = InternalSettings.from_hash(raw)
      settings = internal.to_settings
      settings.normalize
    end

    sig do
      params(general: GeneralSettings, additional: AdditionalSettings)
        .void
    end
    def initialize(general:, additional:)
      @general = general
      @additional = additional
    end

    sig { returns(OnlyOffice::Config::Conversion) }
    def conversion
      @general.conversion
    end

    sig { returns(OnlyOffice::Config::Editor) }
    def editor
      @general.editor
    end

    sig { returns(OnlyOffice::Config::Formats) }
    def formats
      @general.formats
    end

    sig { returns(OnlyOffice::Config::SSL) }
    def ssl
      @general.ssl
    end

    sig { returns(OnlyOffice::Config::JWT) }
    def jwt
      @general.jwt
    end

    sig { returns(OnlyOffice::Config::DocumentServer) }
    def document_server
      @general.document_server
    end

    sig { returns(OnlyOffice::Config::Plugin) }
    def plugin
      @general.plugin
    end

    sig { returns(OnlyOffice::Config::Trial) }
    def trial
      @general.trial
    end

    sig { returns(OnlyOffice::Config::JWT) }
    def fallback_jwt
      @additional.fallback_jwt
    end

    sig { returns(T.untyped) }
    def serialize
      @general.serialize.merge(@additional.serialize)
    end

    sig { returns(T.untyped) }
    def safe_serialize
      @general.safe_serialize.merge(@additional.safe_serialize)
    end

    sig { returns(Settings) }
    def with_trial
      self.class.new(general: @general.with_trial, additional: @additional)
    end

    sig { returns(Settings) }
    def normalize
      self.class.new(general: @general.normalize, additional: @additional)
    end

    sig { returns(OnlyOffice::APP::Config) }
    def app_config
      OnlyOffice::APP::Config.new(
        document: OnlyOffice::APP::Config::Document.new(
          permissions: OnlyOffice::APP::Config::Permissions.new(
            chat: editor.chat_enabled
          )
        ),
        editor_config: OnlyOffice::APP::Config::EditorConfig.new(
          lang: I18n.locale.to_s,
          customization: OnlyOffice::APP::Config::Customization.new(
            compact_header: editor.compact_header_enabled,
            feedback: OnlyOffice::APP::Config::GenericFeedback.new(
              value: editor.feedback_enabled
            ),
            force_save: editor.force_save_enabled,
            help: editor.help_enabled,
            toolbar_no_tabs: editor.toolbar_tabs_disabled
          )
        )
      )
    end

    SaveCallback = T.type_alias do
      T.proc
       .params(patch: Settings, callback: OnlyOffice::API::Conversion)
       .returns(OnlyOffice::API::Conversion)
    end

    sig { params(callback: SaveCallback).void }
    def save(&callback)
      logger.info("Starting the process of saving settings")

      current = self.class.current
      logger.info("Current settings: #{current.safe_serialize}")

      patch = normalize
      logger.info("Patched settings: #{patch.safe_serialize}")

      unless patch.plugin.enabled
        logger.info("Disable plugin")
        begin
          patch.force_save
          OnlyOfficeRedmine::Resources::Formats.read!
        rescue StandardError => e
          current.force_save
          OnlyOfficeRedmine::Resources::Formats.read!
          raise e
        end
        return
      end

      if patch.trial.enabled
        if current.trial.started?
          if current.trial.expired?
            logger.error("Trial expired (#{patch.trial.enabled_at})")
            raise SettingsError.trial_expired
          end
        else
          logger.info("Starting trial")
          patch.trial.start
        end
        logger.info("Saving with trial")
        patch = patch.with_trial
      end

      begin
        patch.force_save

        client = patch.client

        status, response = client.health_check.check
        unless status
          description = "Failed to receive a response to document server health check"
          logger.error("#{description} (#{response.code} #{response.message})")
          raise SettingsError.validation_failed
        end

        version, response = client.command.version
        if version.is_a?(OnlyOffice::API::CommandError)
          logger.error("#{version.description} (#{response.code} #{response.message})")
          raise SettingsError.validation_failed
        end

        conversion = OnlyOffice::API::Conversion.new
        conversion = callback.call(patch, conversion)

        result, response = client.conversion.convert(conversion)
        if result.is_a?(OnlyOffice::API::ConversionError)
          logger.error("#{result.description} (#{response.code} #{response.message})")
          raise SettingsError.validation_failed
        end

        OnlyOfficeRedmine::Resources::Formats.read!
      rescue StandardError => e
        current.force_save
        OnlyOfficeRedmine::Resources::Formats.read!
        raise e
      end

      nil
    end

    sig { void }
    def force_save
      internal = InternalSettings.from_settings(self)
      raw = internal.serialize
      ::Setting.send("#{NAME}=", raw)
    end

    sig { returns(OnlyOffice::API::Client) }
    def client
      base_url = document_server.resolve_internal_url(document_server.url)
      client = OnlyOffice::API::Client.new(base_url:)
      client = client.with_ssl_verify_mode(ssl.verify_mode)
      if jwt.enabled
        client = client.with_jwt(jwt.secret, jwt.algorithm, nil, jwt.http_header)
      end
      client
    end

    sig { returns(Logger) }
    private def logger
      OnlyOfficeRedmine.logger
    end
  end

  class AdditionalSettings
    extend T::Sig

    sig { returns(T.untyped) }
    def safe_serialize
      settings = with(fallback_jwt: fallback_jwt.safe_serialize)
      settings.serialize
    end

    class << self
      extend T::Sig

      sig { returns(AdditionalSettings) }
      attr_reader :defaults
    end

    @defaults = T.let(
      new,
      AdditionalSettings
    )
  end

  class Settings
    class << self
      extend T::Sig

      sig { returns(Settings) }
      attr_reader :defaults
    end

    @defaults = T.let(
      # rubocop:disable Layout/MultilineArrayLineBreaks
      begin
        general = OnlyOffice::Config.defaults
        additional = AdditionalSettings.defaults
        settings = Settings.new(general:, additional:)
        # For backward compatibility and a more planned transition to the 3.0.0.
        settings.formats.editable = [
          "csv", "docxf", "epub", "fb2", "html", "odp", "ods", "odt", "otp",
          "ots", "ott",   "pdfa", "rtf", "txt"
        ]
        settings.jwt.secret = ""
        # Don't trim the slash. The normalized empty path ends with a slash.
        settings.document_server.url = "http://localhost/"
        settings
      end,
      # rubocop:enable Layout/MultilineArrayLineBreaks
      Settings
    )
  end

  class InternalSettings
    extend T::Sig

    sig { params(hash: T.untyped, strict: T.untyped).returns(InternalSettings) }
    def self.from_hash(hash, strict = nil)
      super(hash, strict)
    end

    sig { params(settings: Settings).returns(InternalSettings) }
    def self.from_settings(settings)
      internal = InternalSettings.new

      internal.conversion_timeout            = settings.conversion.timeout.to_s
      internal.editor_chat_enabled           = map_bool(settings.editor.chat_enabled)
      internal.editor_compact_header_enabled = map_bool(settings.editor.compact_header_enabled)
      internal.editor_feedback_enabled       = map_bool(settings.editor.feedback_enabled)
      internal.editor_force_save_enabled     = map_bool(settings.editor.force_save_enabled)
      internal.editor_help_enabled           = map_bool(settings.editor.help_enabled)
      internal.editor_toolbar_tabs_disabled  = map_bool(settings.editor.toolbar_tabs_disabled)

      internal.formats_editable = settings.formats.editable

      internal.ssl_verification_disabled = map_bool(settings.ssl.verification_disabled)

      internal.jwt_secret =
        begin
          if settings.jwt.enabled
            settings.jwt.secret
          else
            ""
          end
        end

      internal.jwt_algorithm = settings.jwt.algorithm
      internal.jwt_http_header = settings.jwt.http_header

      internal.fallback_jwt_secret = settings.fallback_jwt.secret
      internal.fallback_jwt_algorithm = settings.fallback_jwt.algorithm

      internal.document_server_url =
        begin
          if settings.plugin.enabled
            settings.document_server.url
          else
            ""
          end
        end

      internal.document_server_internal_url = settings.document_server.internal_url

      internal.plugin_internal_url = settings.plugin.internal_url

      internal.trial_enabled = map_bool(settings.trial.enabled)
      internal.trial_enabled_at = settings.trial.enabled_at

      internal
    end

    sig { returns(Settings) }
    def to_settings
      general = OnlyOffice::Config.new

      general.conversion.timeout = Integer(conversion_timeout, 10)

      general.editor.chat_enabled           = self.class.unmap_bool(editor_chat_enabled)
      general.editor.compact_header_enabled = self.class.unmap_bool(editor_compact_header_enabled)
      general.editor.feedback_enabled       = self.class.unmap_bool(editor_feedback_enabled)
      general.editor.force_save_enabled     = self.class.unmap_bool(editor_force_save_enabled)
      general.editor.help_enabled           = self.class.unmap_bool(editor_help_enabled)
      general.editor.toolbar_tabs_disabled  = self.class.unmap_bool(editor_toolbar_tabs_disabled)

      general.formats.editable = formats_editable

      general.ssl.verify_mode =
        begin
          ssl_verification_disabled = self.class.unmap_bool(self.ssl_verification_disabled)
          if ssl_verification_disabled
            OpenSSL::SSL::VERIFY_NONE
          else
            OpenSSL::SSL::VERIFY_PEER
          end
        end

      general.jwt.enabled = jwt_secret != ""
      general.jwt.secret = jwt_secret
      general.jwt.algorithm = jwt_algorithm
      general.jwt.http_header = jwt_http_header

      general.document_server.url = document_server_url
      general.document_server.internal_url = document_server_internal_url

      general.plugin.enabled = document_server_url != ""
      general.plugin.internal_url = plugin_internal_url

      general.trial.enabled = self.class.unmap_bool(trial_enabled)
      general.trial.enabled_at = trial_enabled_at

      additional = AdditionalSettings.new

      additional.fallback_jwt.secret = fallback_jwt_secret
      additional.fallback_jwt.algorithm = fallback_jwt_algorithm

      Settings.new(general:, additional:)
    end

    sig { params(value: String).returns(T::Boolean) }
    def self.unmap_bool(value)
      value == "on"
    end

    sig { params(value: T::Boolean).returns(String) }
    def self.map_bool(value)
      value == true ? "on" : ""
    end

    class << self
      extend T::Sig

      sig { returns(InternalSettings) }
      attr_reader :defaults
    end

    @defaults = T.let(
      from_settings(Settings.defaults),
      InternalSettings
    )
  end

  class SettingsError < StandardError
    class << self
      extend T::Sig

      sig { returns(SettingsError) }
      attr_reader :validation_failed

      sig { returns(SettingsError) }
      attr_reader :trial_expired
    end

    @validation_failed = T.let(new("Validation failed"), SettingsError)
    @trial_expired     = T.let(new("Trial expired"), SettingsError)
  end
end
