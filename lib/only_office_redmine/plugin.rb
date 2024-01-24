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

module OnlyOfficeRedmine
  class Plugin
    extend T::Sig

    sig { returns(T.nilable(Plugin)) }
    def self.current
      plugin = Redmine::Plugin.find(NAME)
      unless plugin
        return nil
      end
      new(plugin: plugin)
    end

    sig { params(plugin: Redmine::Plugin).void }
    def initialize(plugin:)
      @plugin = plugin
    end

    sig { returns(T.any(String, Symbol)) }
    def id
      @plugin.id
    end

    sig { returns(T::Boolean) }
    def configurable?
      @plugin.configurable?
    end
  end
end
