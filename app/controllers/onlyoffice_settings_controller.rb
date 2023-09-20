#
# (c) Copyright Ascensio System SIA 2022
# http://www.onlyoffice.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_dependency "attachment"
require_dependency "user"

class OnlyofficeSettingsController < SettingsController

    before_action :require_admin

    require_sudo_mode :save

    def save
        @plugin = Redmine::Plugin.find("onlyoffice_redmine")
        unless @plugin.configurable?
            render_404
            return
        end

        setting = params[:settings] ? params[:settings].permit!.to_h : {}

        setting["oo_address"] = UrlHelper.fix_url(setting["oo_address"])
        setting["inner_editor"] = UrlHelper.fix_url(setting["inner_editor"])
        setting["inner_server"] = UrlHelper.fix_url(setting["inner_server"])

        response = {
            :success => true,
            :message => l(:notice_successful_update)
        }

        begin
            if setting["editor_demo"].eql?("on")
                if Config.is_demo_ended()
                    Setting.plugin_onlyoffice_redmine["editor_demo"] = "off"
                    raise l(:onlyoffice_editor_trial_period_ended)
                end

                start = Setting.plugin_onlyoffice_redmine["demo_date_start"]

                if start.nil? || start.empty?
                    Setting.plugin_onlyoffice_redmine["demo_date_start"] = Time.now.to_s
                end
            end

            Setting.send "plugin_#{@plugin.id}=", setting
        
            is_valid_settings()
            flash[:notice] = l(:notice_successful_update)
        rescue => ex
            response[:success] = false
            response[:message] = ex.message
            flash[:error] = ex.message
        end

        redirect_to plugin_settings_path(@plugin)
    end
    
    def is_valid_settings
        JwtHelper.init
        DocumentHelper.init(request.base_url)

        logger.info("Checking settings")

        url_file = DocumentHelper.get_download_test_settings_url()
        
        begin
            inner_url = Config.get_docserver_url()
            public_url = Config.get_docserver_url(false)

            logger.info("Sending public healthcheck request")
            CallbackHelper.do_request(public_url + "healthcheck", true)
            if (inner_url != public_url)
                logger.info("Sending inner healthcheck request")
                CallbackHelper.do_request(inner_url + "healthcheck", true)
            end
        
            logger.info("Sending version command request")
            res_command = CallbackHelper.command_request("version", nil)
            ds_version = res_command["version"]

            if ds_version.empty?
                raise "Error while sending command request"
            end
        
            logger.info("Checking convert service request")
            res_convert = ServiceConverter.get_converted_uri(Config.get_docserver_url(), "test-convert.txt", url_file, "txt", "docx", Time.now.to_i.to_s)
            convert_percent = res_convert[0]
            converted_file_url = res_convert[1]

            if convert_percent != 100 || converted_file_url.nil? || converted_file_url.empty?
                raise "Error while converting test document"
            end

        rescue => ex
            logger.error("Error while checking settings")
            logger.error(ex)
            raise
        end
        
        return true
    end
end
