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

require "pathname"
require "sorbet-runtime"
require_relative "resource"

module OnlyOffice; end

module OnlyOffice::Resources
  # class Templates
  #   All = T.type_alias do
  #     T::Set[Template]
  #   end
  # end

  # class Template
  #   # https://www.wikiwand.com/en/Language_code
  #   def langauge(standard = "ISO 639"); end
  #   def spreadsheet; end
  #   def presentation; end
  #   def document; end
  #   def path(extenssion); end
  # end

  class Templates
    extend T::Sig
    extend Resource

    sig { params(language: String, format: String).returns(Pathname) }
    def self.file(language, format)
      directory.join("#{language}/new.#{format}")
    end

    sig { override.returns(Pathname) }
    private_class_method def self.directory
      resources = super
      resources.join("document-templates")
    end
  end
end
