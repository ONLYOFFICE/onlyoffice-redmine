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

require "pathname"
require "sorbet-runtime"
require_relative "resource"

module OnlyOffice; end

module OnlyOffice::Resources
  class Template
    extend T::Sig

    attr_accessor :format

    sig { params(format: String, directory: Pathname).void }
    def initialize(format:, directory:)
      @format = format

      directory = directory.dup
      @directory = T.let(directory, Pathname)
    end
  end

  class Templates
    extend T::Sig
    extend Resource

    sig { override.returns(Pathname) }
    private_class_method def self.directory
      resources = super
      resources.join("document-templates")
    end

    sig { params(all: All).void }
    def initialize(all:)
      @all = all
    end

    sig { returns(All) }
    def all
      @all.dup
    end
  end

  class Template
    sig do
      params(code: String, scheme: TemplatesLanguageScheme)
        .returns(Pathname)
    end
    def blank(code, scheme = TemplatesLanguageScheme.iso3166_1)
      code = scheme.resolve(code) || "en-US"
      @directory.join("#{code}/new.#{@format}")
    end
  end

  class TemplatesLanguageScheme
    extend T::Sig

    # rubocop:disable Naming/VariableNumber, Style/StringHashKeys
    sig { returns(TemplatesLanguageScheme) }
    def self.iso639_1
      scheme = {
        "de" => "de-DE",
        "en" => "en-US",
        "es" => "es-ES",
        "fr" => "fr-FR",
        "it" => "it-IT",
        "ja" => "ja-JP",
        "pt" => "pt-PT",
        "ru" => "ru-RU",
        "zh" => "zh-CN"
      }
      new(scheme: scheme)
    end

    sig { returns(TemplatesLanguageScheme) }
    def self.iso3166_1
      scheme = {
        "de-DE" => "de-DE",
        "en-US" => "en-US",
        "es-ES" => "es-ES",
        "fr-FR" => "fr-FR",
        "it-IT" => "it-IT",
        "ja-JP" => "ja-JP",
        "pt-BR" => "pt-BR",
        "pt-PT" => "pt-PT",
        "ru-RU" => "ru-RU",
        "zh-CN" => "zh-CN"
      }
      new(scheme: scheme)
    end
    # rubocop:enable Naming/VariableNumber, Style/StringHashKeys

    sig { params(scheme: T::Hash[String, String]).void }
    def initialize(scheme:)
      @scheme = scheme
    end

    sig { params(code: String).returns(T.nilable(String)) }
    def resolve(code)
      @scheme[code]
    end
  end
end
