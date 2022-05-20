class Config
    @trial_data = { 
                "oo_address" => "https://onlinedocs.onlyoffice.com/", 
                "jwtHeader" => "AuthorizationJWT",
                "jwtsecret" => "sn2puSUF7muF5Jas",
                "trial" => 30
            }

    class << self

        def get_config(key, for_settings = false)
            get = (Setting.plugin_onlyoffice_redmine["editor_demo"].eql?("on") && istrial) || for_settings ? @trial_data[key] : Setting.plugin_onlyoffice_redmine[key]
            return key.eql?("oo_address") ? check_valid_url(get) : get
        end

        def istrial
            demo_date = Setting.plugin_onlyoffice_redmine["demo_date_start"]
            if !demo_date.nil? && !demo_date.eql?("")
                if Time.now < Time.parse(demo_date) + (@trial_data['trial']*24*60*60)
                    return true
                else
                    return false
                end
            end
            return false
        end

        def check_valid_url(url)
            url = url.present? ? url : ""
            check_url = url[-1].eql?("/") ? url : url + "/"
            check_url = check_url.eql?("/") ? "" : check_url
            return check_url
        end

    end
end