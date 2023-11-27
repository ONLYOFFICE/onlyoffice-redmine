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

require "sorbet-runtime"
require_relative "formats"
require_relative "templates"
require_relative "templates+formats"

module OnlyOffice; end

module OnlyOffice::Resources
  class Formats
    sig { returns(T::Array[Format]) }
    def creatable
      @all.filter(&:creatable?)
    end
  end

  class Format
    sig { returns(T::Boolean) }
    def creatable?
      name == "docx" ||
        name == "docxf" ||
        name == "pptx" ||
        name == "xlsx"
    end

    sig { returns(T.nilable(Template)) }
    def template
      templates = Templates.read
      templates.all.find do |template|
        template.format == @name
      end
    end
  end
end
