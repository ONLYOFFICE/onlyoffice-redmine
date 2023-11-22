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
    prop :document_server_url,           String,           default: "", name: "oo_address"
    prop :document_server_internal_url,  String,           default: "", name: "inner_editor"
    prop :plugin_internal_url,           String,           default: "", name: "inner_server"
    prop :trial_enabled,                 String,           default: "", name: "editor_demo"
    prop :trial_enabled_at,              String,           default: "", name: "demo_date_start"
  end

  class Settings
    extend T::Sig

    NAME = "plugin_#{OnlyOfficeRedmine::NAME}".freeze

    sig { returns(OnlyOfficeRedmine::Settings) }
    def self.current
      raw = ::Setting.send(NAME)
      internal = InternalSettings.from_hash(raw)
      config = internal.to_config
      config.normalize!
      new(config:)
    end

    sig { params(config: OnlyOffice::Config).void }
    def initialize(config:)
      @config = config
    end

    sig { returns(OnlyOffice::Config::Conversion) }
    def conversion
      @config.conversion
    end

    sig { returns(OnlyOffice::Config::Editor) }
    def editor
      @config.editor
    end

    sig { returns(OnlyOffice::Config::Formats) }
    def formats
      @config.formats
    end

    sig { returns(OnlyOffice::Config::SSL) }
    def ssl
      @config.ssl
    end

    sig { returns(OnlyOffice::Config::JWT) }
    def jwt
      @config.jwt
    end

    sig { returns(OnlyOffice::Config::DocumentServer) }
    def document_server
      @config.document_server
    end

    sig { returns(OnlyOffice::Config::Plugin) }
    def plugin
      @config.plugin
    end

    sig { returns(OnlyOffice::Config::Trial) }
    def trial
      @config.trial
    end

    sig { returns(T.untyped) }
    def serialize
      @config.serialize
    end

    sig { returns(T.untyped) }
    def safe_serialize
      @config.safe_serialize
    end

    sig { returns(OnlyOfficeRedmine::Settings) }
    def with_trial
      self.class.new(config: @config.with_trial)
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
       .params(callback: OnlyOffice::API::Conversion)
       .returns(OnlyOffice::API::Conversion)
    end

    sig { params(callback: SaveCallback).void }
    def save(&callback)
      logger.info("Starting the process of saving settings")

      current = self.class.current
      logger.info("Current settings: #{current.safe_serialize}")

      patch = self
      logger.info("Patched settings: #{patch.safe_serialize}")

      unless patch.plugin.enabled
        logger.info("Disable plugin")
        begin
          patch.force_save
          OnlyOfficeRedmine::Resources::Formats.read!
        rescue StandardError => error
          current.force_save
          OnlyOfficeRedmine::Resources::Formats.read!
          raise error
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
        conversion = callback.call(conversion)
        conversion.url = patch.plugin.resolve_internal_url(conversion.url)

        result, response = client.conversion.convert(conversion)
        if result.is_a?(OnlyOffice::API::ConversionError)
          logger.error("#{result.description} (#{response.code} #{response.message})")
          raise SettingsError.validation_failed
        end

        OnlyOfficeRedmine::Resources::Formats.read!
      rescue StandardError => error
        current.force_save
        OnlyOfficeRedmine::Resources::Formats.read!
        raise error
      end

      nil
    end

    sig { void }
    def force_save
      internal = InternalSettings.from_config(@config)
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

  class InternalSettings
    extend T::Sig

    sig { params(hash: T.untyped, strict: T.untyped).returns(InternalSettings) }
    def self.from_hash(hash, strict = nil)
      super(hash, strict)
    end

    sig { params(config: OnlyOffice::Config).returns(InternalSettings) }
    def self.from_config(config)
      internal = InternalSettings.new

      internal.conversion_timeout            = config.conversion.timeout.to_s
      internal.editor_chat_enabled           = map_bool(config.editor.chat_enabled)
      internal.editor_compact_header_enabled = map_bool(config.editor.compact_header_enabled)
      internal.editor_feedback_enabled       = map_bool(config.editor.feedback_enabled)
      internal.editor_force_save_enabled     = map_bool(config.editor.force_save_enabled)
      internal.editor_help_enabled           = map_bool(config.editor.help_enabled)
      internal.editor_toolbar_tabs_disabled  = map_bool(config.editor.toolbar_tabs_disabled)

      internal.formats_editable = config.formats.editable

      internal.ssl_verification_disabled = map_bool(config.ssl.verification_disabled)

      internal.jwt_secret =
        begin
          if config.jwt.enabled
            config.jwt.secret
          else
            ""
          end
        end

      internal.jwt_algorithm = config.jwt.algorithm
      internal.jwt_http_header = config.jwt.http_header

      internal.document_server_url =
        begin
          if config.plugin.enabled
            config.document_server.url
          else
            ""
          end
        end

      internal.document_server_internal_url = config.document_server.internal_url

      internal.plugin_internal_url = config.plugin.internal_url

      internal.trial_enabled = map_bool(config.trial.enabled)
      internal.trial_enabled_at = config.trial.enabled_at

      internal
    end

    sig { returns(OnlyOffice::Config) }
    def to_config
      config = OnlyOffice::Config.new

      config.conversion.timeout = Integer(conversion_timeout, 10)

      config.editor.chat_enabled           = self.class.unmap_bool(editor_chat_enabled)
      config.editor.compact_header_enabled = self.class.unmap_bool(editor_compact_header_enabled)
      config.editor.feedback_enabled       = self.class.unmap_bool(editor_feedback_enabled)
      config.editor.force_save_enabled     = self.class.unmap_bool(editor_force_save_enabled)
      config.editor.help_enabled           = self.class.unmap_bool(editor_help_enabled)
      config.editor.toolbar_tabs_disabled  = self.class.unmap_bool(editor_toolbar_tabs_disabled)

      config.formats.editable = formats_editable

      config.ssl.verify_mode =
        begin
          ssl_verification_disabled = self.class.unmap_bool(self.ssl_verification_disabled)
          if ssl_verification_disabled
            OpenSSL::SSL::VERIFY_NONE
          else
            OpenSSL::SSL::VERIFY_PEER
          end
        end

      config.jwt.enabled = jwt_secret != ""
      config.jwt.secret = jwt_secret
      config.jwt.algorithm = jwt_algorithm
      config.jwt.http_header = jwt_http_header

      config.document_server.url = document_server_url
      config.document_server.internal_url = document_server_internal_url

      config.plugin.enabled = document_server_url != ""
      config.plugin.internal_url = plugin_internal_url

      config.trial.enabled = self.class.unmap_bool(trial_enabled)
      config.trial.enabled_at = trial_enabled_at

      config
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
      # rubocop:disable Layout/MultilineArrayLineBreaks
      begin
        defaults = OnlyOffice::Config.defaults
        internal = from_config(defaults)
        # For backward compatibility and a more planned transition to the 3.0.0.
        internal.formats_editable = [
          "csv", "docxf", "epub", "fb2", "html", "odp", "ods", "odt", "otp",
          "ots", "ott",   "pdfa", "rtf", "txt"
        ]
        # Don't trim the slash. The normalized empty path ends with a slash.
        internal.document_server_url = "http://localhost/"
        internal
      end,
      # rubocop:enable Layout/MultilineArrayLineBreaks
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
