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

require "openssl"
require "securerandom"
require "time"
require "uri"
require "sorbet-runtime"

module OnlyOffice
  class Config < T::Struct
    class Conversion < T::Struct
      prop :timeout, Integer, default: 120_000 # 2 minutes
    end

    class Editor < T::Struct
      prop :chat_enabled,           T::Boolean, default: true
      prop :compact_header_enabled, T::Boolean, default: false
      prop :feedback_enabled,       T::Boolean, default: true
      prop :force_save_enabled,     T::Boolean, default: false
      prop :help_enabled,           T::Boolean, default: true
      prop :toolbar_tabs_disabled,  T::Boolean, default: false
    end

    class Formats < T::Struct
      prop :editable, T::Array[String], default: ["csv", "txt"]
    end

    class SSL < T::Struct
      prop :verify_mode, Integer, default: OpenSSL::SSL::VERIFY_PEER
    end

    class JWT < T::Struct
      prop :enabled,     T::Boolean, default: true
      prop :secret,      String,     factory: lambda { SecureRandom.hex(64) }, sensitivity: []
      prop :algorithm,   String,     default: "HS256"
      prop :http_header, String,     default: "Authorization"
    end

    module InP
      extend T::Sig
      extend T::Helpers
      abstract!

      sig { abstract.returns(String) }
      def url; end

      sig { abstract.params(url: String).returns(String) }
      def url=(url); end

      sig { abstract.returns(String) }
      def internal_url; end

      sig { abstract.params(url: String).returns(String) }
      def internal_url=(url); end
    end

    class DocumentServer < T::Struct
      include InP

      prop :url,          String, default: ""
      prop :internal_url, String, default: ""
    end

    class Plugin < T::Struct
      include InP

      prop :enabled,      T::Boolean, default: true
      prop :url,          String,     default: ""
      prop :internal_url, String,     default: ""
    end

    class Trial < T::Struct
      prop :enabled,    T::Boolean, default: false
      prop :enabled_at, String,     default: ""
      prop :period,     Integer,    default: 2_592_000 # 30 days
    end

    prop :conversion,      Conversion,     default: Conversion.new
    prop :editor,          Editor,         default: Editor.new
    prop :formats,         Formats,        default: Formats.new
    prop :ssl,             SSL,            default: SSL.new
    prop :jwt,             JWT,            default: JWT.new
    prop :document_server, DocumentServer, default: DocumentServer.new
    prop :plugin,          Plugin,         default: Plugin.new
    prop :trial,           Trial,          default: Trial.new

    class << self
      extend T::Sig

      sig { returns(Config) }
      attr_reader :defaults

      sig { returns(Config) }
      attr_reader :trial
    end

    @defaults = T.let(
      new,
      Config
    )

    @trial = T.let(
      begin
        config = new
        config.jwt.secret = "sn2puSUF7muF5Jas"
        config.jwt.http_header = "AuthorizationJWT"
        # Don't trim the slash. The normalized empty path ends with a slash.
        config.document_server.url = "https://onlinedocs.onlyoffice.com/"
        config
      end,
      Config
    )

    extend T::Sig

    sig { params(hash: T.untyped, strict: T.untyped).returns(Config) }
    def self.from_hash(hash, strict = nil)
      super(hash, strict)
    end

    sig { returns(T.untyped) }
    def safe_serialize
      config = with(jwt: jwt.safe_serialize)
      config.serialize
    end

    sig { returns(Config) }
    def with_trial
      trial = self.class.trial
      config = copy
      config.jwt.define_singleton_method(:enabled) do
        trial.jwt.enabled
      end
      config.jwt.define_singleton_method(:secret) do
        trial.jwt.secret
      end
      config.jwt.define_singleton_method(:algorithm) do
        trial.jwt.algorithm
      end
      config.jwt.define_singleton_method(:http_header) do
        trial.jwt.http_header
      end
      config.document_server.define_singleton_method(:url) do
        trial.document_server.url
      end
      config.document_server.define_singleton_method(:internal_url) do
        trial.document_server.internal_url
      end
      config.plugin.define_singleton_method(:internal_url) do
        trial.plugin.internal_url
      end
      config
    end

    sig { returns(OnlyOffice::Config) }
    def normalize
      config = copy
      config.normalize!
      config
    end

    sig { void }
    def normalize!
      document_server.normalize!
      plugin.normalize!
    end

    sig { returns(Config) }
    private def copy
      self.class.new(
        conversion: conversion.dup,
        editor: editor.dup,
        formats: formats.dup,
        ssl: ssl.dup,
        jwt: jwt.clone,
        document_server: document_server.clone,
        plugin: plugin.clone,
        trial: trial.dup
      )
    end

    class JWT
      extend T::Sig

      sig { returns(T.untyped) }
      def safe_serialize
        jwt = with(secret: "***")
        jwt.serialize
      end
    end

    module InP
      include Kernel

      sig { overridable.returns(InP) }
      def normalize
        inp = clone
        inp.normalize!
        inp
      end

      sig { void }
      def normalize!
        # The problem is that the URI normalizer returns a slash if the URL was
        # actually a slash, and at the same time if the URL was just empty.
        #
        # ```ruby
        # URI("/").normalize.to_s # "/"
        # URI("").normalize.to_s  # "/" too
        # ```
        #
        # To avoid side effects after normalization, an additional check is
        # required to determine whether the slash was actually specified or
        # whether it's a result of normalization.
        #
        # ```ruby
        # inp.url == "" # true
        # inp.normalize!
        # inp.url == "" # false, it's "/"
        # ```

        uri = self.uri.normalize
        if uri.to_s == "/" && url != "/"
          self.url = ""
        else
          self.uri = uri
        end

        uri = internal_uri.normalize
        if uri.to_s == "/" && internal_url != "/"
          self.internal_url = ""
        else
          self.internal_uri = uri
        end
      end

      sig { params(uri: URI::Generic).returns(URI::Generic) }
      def resolve_internal_uri(uri)
        pub = uri.to_s
        internal = resolve_internal_url(pub)
        URI(internal)
      end

      sig { params(url: String).returns(String) }
      def resolve_internal_url(url)
        unless internal?
          return url.dup
        end
        url.sub(self.url, internal_url)
      end

      sig { params(uri: URI::Generic).returns(URI::Generic) }
      def resolve_uri(uri)
        internal = uri.to_s
        pub = resolve_url(internal)
        URI(pub)
      end

      sig { params(url: String).returns(String) }
      def resolve_url(url)
        unless internal?
          return url.dup
        end
        url.sub(internal_url, self.url)
      end

      sig { returns(T::Boolean) }
      def internal?
        internal_url != "" && internal_uri != uri
      end

      sig { params(uri: URI::Generic).void }
      def internal_uri=(uri)
        self.internal_url = uri.to_s
      end

      sig { returns(URI::Generic) }
      def internal_uri
        URI(internal_url)
      end

      sig { params(uri: URI::Generic).void }
      def uri=(uri)
        self.url = uri.to_s
      end

      sig { returns(URI::Generic) }
      def uri
        URI(url)
      end
    end

    class DocumentServer
      extend T::Sig

      # rubocop:disable Lint/UselessMethodDefinition
      sig { override.returns(DocumentServer) }
      def normalize
        # This isn't a useless method, it overrides the return type.
        super
      end
      # rubocop:enable Lint/UselessMethodDefinition
    end

    class Plugin
      extend T::Sig

      # rubocop:disable Lint/UselessMethodDefinition
      sig { override.returns(Plugin) }
      def normalize
        # This isn't a useless method, it overrides the return type.
        super
      end
      # rubocop:enable Lint/UselessMethodDefinition
    end

    class Trial
      extend T::Sig

      sig { returns(T::Boolean) }
      def started?
        enabled_at != ""
      end

      sig { returns(T::Boolean) }
      def expired?
        Time.now.utc > enabled_time + period
      end

      sig { void }
      def reset
        disable
        self.enabled_at = ""
      end

      sig { void }
      def disable
        self.enabled = false
      end

      sig { void }
      def enable
        self.enabled = true
      end

      sig { void }
      def start
        self.enabled_time = Time.now.utc
      end

      sig { params(time: Time).void }
      def enabled_time=(time)
        self.enabled_at = time.to_s
      end

      sig { returns(Time) }
      def enabled_time
        Time.parse(enabled_at)
      end
    end
  end
end
