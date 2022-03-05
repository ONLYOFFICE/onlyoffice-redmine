class Config
    @trialData = nil
    @config = nil
    class << self
        def init
            if Setting.plugin_onlyoffice_redmine["editor_demo"].eql?("on") ? true : false
                path = Rails.root.join('plugins', 'onlyoffice_redmine', 'config', 'config.yaml')
                if File.exists?(path) && 
                    @config = JSON.parse(File.open(path, 'r'){ |file| file.read })
                    if @config["data"] = "none"
                        create_trial_data
                        @config = JSON.parse(File.open(path, 'r'){ |file| file.read })
                    end
                end
            end

            @trialData = { 
                "oo_address" => "https://onlinedocs.onlyoffice.com/", 
                "jwtHeader" => "AuthorizationJWT",
                "jwtsecret" => "sn2puSUF7muF5Jas", 
            }
        end

        def get_config(key)
            if key == "jwtHeader"
                get = "Authorization"
            else
                get = Setting.plugin_onlyoffice_redmine[key]
            end
            
            if Setting.plugin_onlyoffice_redmine["editor_demo"].eql?("on") ? true : false && istrial
                init
                get = @trialData[key]
            end
            return get
        end

        def istrial
            init
            unless @config.nil?
                if Time.now < Time.parse(@config["data"]) + (@config['trial']*24*60*60)
                    return true
                end
            end
            return false
        end

        def replace_editor_url(url)
            init
            newUrl = get_config("oo_address")
            docUrl = Setting.plugin_onlyoffice_redmine["oo_address"]
            return url.sub(docUrl, newUrl)
        end

        def create_trial_data
            path = Rails.root.join('plugins', 'onlyoffice_redmine', 'config', 'config.yaml')
            data = { 
                "data" => Time.now, 
                "trial" => 30,
            }
            File.open(path, 'w'){ |file| file.write data.to_json }
        end
    end
end