class Config
  @trial_data = { 
    "oo_address" => "https://onlinedocs.onlyoffice.com/", 
    "jwtheader" => "AuthorizationJWT",
    "jwtsecret" => "sn2puSUF7muF5Jas",
    "trial" => 30
  }

  class << self

    def get_config(key, for_settings = false)
      get = (Setting.plugin_onlyoffice_redmine["editor_demo"].eql?("on") && istrialended) || for_settings ? @trial_data[key] : Setting.plugin_onlyoffice_redmine[key]
      return UrlHelper.fix_url(get)
    end

    def get_docserver_url(internal = true)
      url = nil
      if internal
        url = Setting.plugin_onlyoffice_redmine["inner_editor"]
      end
      if url.nil? || url.empty?
        url = Setting.plugin_onlyoffice_redmine["oo_address"]
      end
      return UrlHelper.fix_url(url)
    end

    def get_redmine_url(redmine_url)
      url = Setting.plugin_onlyoffice_redmine["inner_server"]
      return UrlHelper.fix_url(url.present? ? url : redmine_url)
    end

    def get_jwt_secret()
      return Setting.plugin_onlyoffice_redmine["jwtsecret"]
    end

    def get_jwt_header()
      header = Setting.plugin_onlyoffice_redmine["jwtheader"]
      if header.nil? || header.empty?
        header = "Authorization"
      end

      return header
    end

    def istrialended
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

  end
end