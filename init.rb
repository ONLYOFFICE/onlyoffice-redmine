require 'redmine'

Redmine::Plugin.register :onlyoffice_redmine do
  name 'ONLYOFFICE Redmine plugin'
  author 'ONLYOFFICE'
  description 'Redmine ONLYOFFICE integration plugin'
  version '0.0.1'
  url 'https://github.com/ONLYOFFICE/onlyoffice-redmine'
  author_url 'https://www.onlyoffice.com'


  settings default: {'oo_address' => 'http://localhost/',
                     'jwtsecret' => '',
                     'editor_chat' => 'on',
                     'editor_help' => 'on',
                     'editor_compact_header' => '',
                     'editor_toolbar_no_tabs' => '',
                     'editor_feedback' => 'on'}, partial: 'settings/onlyoffice_settings'
end
