require 'redmine'

Redmine::Plugin.register :onlyoffice_redmine do
  name 'Redmine ONLYOFFICE integration plugin'
  author 'ONLYOFFICE'
  description 'Redmine ONLYOFFICE integration plugin allows opening files uploaded to the Issues, Files, Documents, Wiki, or News modules for viewing and co-editing.'
  version '1.0.0'
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
