class Config
  @trial_data = { 
    "oo_address" => "https://onlinedocs.onlyoffice.com/",
    "inner_editor" => "",
    "inner_server" => "",
    "jwtheader" => "AuthorizationJWT",
    "jwtsecret" => "sn2puSUF7muF5Jas",
    "trial" => 30
  }

  class << self

    def get_docserver_url(internal = true)
      url = nil
      if internal
        url = get_config("inner_editor")
      end
      if url.nil? || url.empty?
        url = get_config("oo_address")
      end
      return UrlHelper.fix_url(url)
    end

    def get_redmine_url(redmine_url)
      url = get_config("inner_server")
      return UrlHelper.fix_url(url.present? ? url : redmine_url)
    end

    def get_jwt_secret()
      return get_config("jwtsecret")
    end

    def get_jwt_header()
      header = get_config("jwtheader")
      if header.nil? || header.empty?
        header = "Authorization"
      end

      return header
    end

    def is_demo()
      return Setting.plugin_onlyoffice_redmine["editor_demo"].eql?("on") && !is_demo_ended()
    end

    def is_demo_ended()
      demo_start = Setting.plugin_onlyoffice_redmine["demo_date_start"]
      if !demo_start.nil? && !demo_start.empty? && Time.now > Time.parse(demo_start) + (@trial_data['trial']*24*60*60)
          return true
      end
      return false
    end

    private 

    def get_config(key)
      if is_demo() && !is_demo_ended()
        return @trial_data[key]
      end
  
      return Setting.plugin_onlyoffice_redmine[key]
    end

  end

end