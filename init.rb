require 'redmine'

Redmine::Plugin.register :onlyoffice_redmine do
  name 'Onlyoffice Redmine plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'


  settings default: {'oo_address' => 'http://localhost/'}, partial: 'settings/onlyoffice_settings'
end
