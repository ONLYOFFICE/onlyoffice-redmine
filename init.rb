require 'redmine'

Redmine::Plugin.register :onlyoffice_redmine do
  name 'Onlyoffice Redmine plugin'
  author 'ONLYOFFICE'
  description 'Redmine ONLYOFFICE integration plugin'
  version '0.0.1'
  url 'https://github.com/ONLYOFFICE/onlyoffice-redmine'
  author_url 'https://www.onlyoffice.com'


  settings default: {'oo_address' => 'http://localhost/',
                     'forcesave' => '',
                     'jwtsecret' => '',
                     'editor_format_odt' => '',
                     'editor_format_ods' => '',
                     'editor_format_odp' => '',
                     'editor_format_csv' => 'on',
                     'editor_format_txt' => 'on',
                     'editor_format_rtf' => '',
                     'editor_chat' => 'on',
                     'editor_help' => 'on',
                     'editor_compact_header' => '',
                     'editor_toolbar_no_tabs' => '',
                     'editor_feedback' => 'on'}, partial: 'settings/onlyoffice_settings'
end
