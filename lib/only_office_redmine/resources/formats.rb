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

module OnlyOfficeRedmine::Resources
  class Formats
    extend T::Sig

    All = T.type_alias do
      OnlyOffice::Resources::Formats::All
    end

    Format = T.type_alias do
      OnlyOffice::Resources::Format
    end

    @mutex = T.let(Mutex.new, Mutex)

    sig { returns(Formats) }
    def self.read!
      unread
      read
    end

    sig { void }
    def self.unread
      unless defined?(@read)
        return
      end
      remove_instance_variable(:@read)
    end

    sig { returns(Formats) }
    def self.read
      @mutex.synchronize do
        unless defined?(@read)
          @read = load
        end
      end
      @read
    end

    sig { returns(Formats) }
    private_class_method def self.load
      all = T.let(Set.new, All)
      settings = OnlyOfficeRedmine::Settings.current
      formats = OnlyOffice::Resources::Formats.read

      formats.all.each do |format|
        format = format.dup
        settings.formats.editable.each do |name|
          unless format.name == name
            next
          end
          format.allow_editing
        end
        all.add(format)
      end

      OnlyOffice::Resources::Formats.unread
      new(all:)
    end

    sig { params(all: All).void }
    def initialize(all:)
      @all = all
    end

    sig { returns(T::Array[Format]) }
    def creatable
      @all.filter(&:creatable?)
    end

    sig { returns(All) }
    def all
      @all.dup
    end
  end
end
