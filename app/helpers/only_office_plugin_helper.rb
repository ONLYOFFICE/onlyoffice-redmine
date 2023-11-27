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

module OnlyOfficePluginHelper
  module Regular
    extend T::Sig
    extend T::Helpers
    include Kernel
    abstract!

    sig { void }
    private def require_onlyoffice_plugin
      require_onlyoffice_plugin_to_be_exist
      require_onlyoffice_plugin_to_be_enalbed
    end

    sig { void }
    private def require_onlyoffice_plugin_to_be_exist
      plugin = OnlyOfficeRedmine::Plugin.current
      unless !plugin.nil? && plugin.configurable?
        raise OnlyOfficeRedmine::Error.not_found
      end
      nil
    end

    sig { void }
    private def require_onlyoffice_plugin_to_be_enalbed
      settings = OnlyOfficeRedmine::Settings.current
      unless settings.plugin.enabled
        raise OnlyOfficeRedmine::Error.not_found
      end
      nil
    end
  end

  module Injection
    extend T::Sig
    extend T::Helpers
    abstract!

    sig { returns(T::Boolean) }
    private def onlyoffice_plugin_available?
      plugin = OnlyOfficeRedmine::Plugin.current
      unless !plugin.nil? && plugin.configurable?
        return false
      end

      settings = OnlyOfficeRedmine::Settings.current
      unless settings.plugin.enabled
        return false
      end

      true
    end
  end
end
