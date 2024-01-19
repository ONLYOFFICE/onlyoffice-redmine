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

require "sorbet-runtime"
require_relative "formats"
require_relative "resource"
require_relative "templates"
require_relative "formats+templates"

module OnlyOffice; end

module OnlyOffice::Resources
  class Templates
    All = T.type_alias do
      T::Set[Template]
    end
  end

  class Templates
    @mutex = T.let(Mutex.new, Mutex)

    sig { returns(Templates) }
    def self.read
      @mutex.synchronize do
        unless defined?(@read)
          @read = load
        end
      end
      @read
    end

    sig { returns(Templates) }
    private_class_method def self.load
      all = T.let(Set.new, All)
      formats = Formats.read
      formats.all.each do |format|
        unless format.creatable?
          next
        end
        template = Template.new(format: format.name, directory: directory)
        all.add(template)
      end
      new(all: all)
    end
  end
end
