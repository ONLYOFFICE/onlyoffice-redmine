# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'onlyoffice/download/:id/:filename', :to => 'onlyoffice#download', :id => /\d+/, :filename => /.*/
get 'onlyoffice/download/:id', :to => 'onlyoffice#download', :id => /\d+/

get 'onlyoffice/editor', :to => 'onlyoffice#editor'