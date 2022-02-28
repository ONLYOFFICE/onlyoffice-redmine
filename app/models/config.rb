class Config
    @trialData = nil
    @config = nil
    class << self
        def init
            path = Rails.root.join('plugins', 'onlyoffice_redmine', 'config', 'config.yaml')
            @config = JSON.parse(JWTHelper.decode(File.open(path, 'r'){ |file| file.read }, "secret"))
            @trialData = { 
                "oo_address" => @config["oo_address"], 
                "jwtHeader" => @config["jwtHeader"],
                "jwtsecret" => @config["jwtsecret"], 
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
            if Time.now < Time.parse(@config["data"]) + (86400 * @config["trial"])
                return true
            end
            return false
        end

        def update_url(url)
            init
            newUrl = get_config("oo_address")
            docUrl = Setting.plugin_onlyoffice_redmine["oo_address"]
            return url.sub(docUrl, newUrl)
        end
    end
end