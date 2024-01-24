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

module OnlyOfficeSettingsHelper
  extend T::Sig
  extend T::Helpers
  include Kernel
  abstract!

  sig { returns(T.untyped) }
  private def redirect_to_plugin_settings
    ac = T.cast(self, ApplicationController)

    plugin = OnlyOfficeRedmine::Plugin.current
    unless plugin
      return ac.redirect_to(ac.helpers.home_url)
    end

    settings = ac.helpers.plugin_settings_path(plugin.id)
    ac.redirect_to(settings)
  end

  sig { void }
  private def check_trial
    ac = T.cast(self, ApplicationController)

    settings = OnlyOfficeRedmine::Settings.current
    if settings.trial.enabled && settings.trial.started? && settings.trial.expired?
      ac.logger.error("Trial expired (#{settings.trial.enabled_at})")
      raise OnlyOfficeRedmine::SettingsError.trial_expired
    end

    nil
  end

  sig { params(error: OnlyOfficeRedmine::SettingsError).returns(T.untyped) }
  private def handle_settings_error(error)
    case error
    when OnlyOfficeRedmine::SettingsError.trial_expired
      render_error(
        {
          message: I18n.t("onlyoffice_editor_trial_period_ended"),
          status: 402
        }
      )
    else
      # do nothing
    end
  end
end
