#
# (c) Copyright Ascensio System SIA 2022
# http://www.onlyoffice.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

get 'onlyoffice/download/:id/:filename', :to => 'onlyoffice#download', :id => /\d+/, :filename => /.*/
get 'onlyoffice/download/:id', :to => 'onlyoffice#download', :id => /\d+/
get 'onlyoffice/download_test', :to => 'onlyoffice#download_test'
get 'onlyoffice/editor/:id', :to => 'onlyoffice#editor', :id => /\d+/, :as => 'onlyoffice_editor'
get 'onlyoffice/editor/:id/:action_data', :to => 'onlyoffice#editor', :id => /\d+/, :action_data => /.*/

post 'onlyoffice/callback/:id/:rss', :to => 'onlyoffice#callback', :id => /\d+/, :rss => /.*/
post 'onlyoffice/save_as/:id', :to => 'onlyoffice#save_as', :id => /\d+/, :as => 'onlyoffice_save_as'

get 'onlyoffice_create/new/:ext/:project_id', :to => 'onlyoffice_create#new', :as => 'onlyoffice_create_new'
get 'onlyoffice_create/new/:project_id/:document_id/:ext', :to => 'onlyoffice_create#new', :as => 'onlyoffice_create_new_2'

post 'onlyoffice_create/new/:ext/:project_id', :to => 'onlyoffice_create#create', :as => 'onlyoffice_create'

post 'onlyoffice_create/attachment/:document_id/:project_id', :to => 'onlyoffice_create#new_doc_attachment', :as => 'onlyoffice_create_new_doc_attachment'
post 'onlyoffice_create/attachment/:project_id/:document_id/:ext', :to => 'onlyoffice_create#new_doc_attachment', :as => 'onlyoffice_create_new_doc_attachment_2'

#   convert file
get 'onlyoffice/conversion/:page_id/:page_type/:id', :to => 'onlyoffice_convert#convert_page', :id => /\d+/, :page_id => /\d+/, :as => 'onlyoffice_convert_convert_page'

post 'onlyoffice/conversion/:page_id/:page_type', :to => 'onlyoffice_convert#convert', :as => 'onlyoffice_convert', :page_id => /\d+/
post 'onlyoffice/settings', :to => 'onlyoffice_settings#save', :as => 'onlyoffice_plugin_settings'
