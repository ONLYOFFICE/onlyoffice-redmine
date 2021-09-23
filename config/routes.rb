# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'onlyoffice/download/:id/:filename', :to => 'onlyoffice#download', :id => /\d+/, :filename => /.*/
get 'onlyoffice/download/:id', :to => 'onlyoffice#download', :id => /\d+/
get 'onlyoffice/editor/:id', :to => 'onlyoffice#editor', :id => /\d+/
get 'onlyoffice/editor/:id/:action_data', :to => 'onlyoffice#editor', :id => /\d+/, :action_data => /.*/

post 'onlyoffice/callback/:id/:rss', :to => 'onlyoffice#callback', :id => /\d+/, :rss => /.*/