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

class DocumentHelper

  @@base_url = nil

  class << self

    def init (url)
    @@base_url = Config.get_redmine_url(url)

      if Setting.plugin_onlyoffice_redmine["onlyoffice_key"].eql?(nil)
        Setting.plugin_onlyoffice_redmine["onlyoffice_key"] = Token.generate_token_value
      end
    end

  def get_download_url(id, user_id)
      payload = {
        :attachment_id => id,
        :type => "download",
        :userid => user_id
      }
    return @@base_url + "onlyoffice/download/#{id}?key=#{JwtHelper.encode(payload, Setting.plugin_onlyoffice_redmine["onlyoffice_key"])}"
    end

  def get_download_test_settings_url()
    return @@base_url + "onlyoffice/download_test/"
  end

  def get_callback_url(id, user)
      payload = {
        :attachment_id => id,
        :type => "callback"
      }
    url = @@base_url + "onlyoffice/callback/#{id}/#{user.rss_key}?key=#{JwtHelper.encode(payload, Setting.plugin_onlyoffice_redmine["onlyoffice_key"])}"
    end

    def file_name_without_ext(file_name)
      name = File.basename(file_name, ".*")
    end

    def file_ext(file_name, remove_dot = false)
      ext = File.extname(file_name).downcase
      return remove_dot ? ext.delete(".") : ext;
    end

    def permission_to_edit_file(user, project, container_type)
      case container_type
        when "Project"
          then return false
        when "Issue"
          then return user.allowed_to?(:edit_issues, project)
        when "News"
          then return user.allowed_to?(:manage_news, project)
        when "Document"
          then return user.allowed_to?(:edit_documents, project)
        when "WikiPage"
          then return user.allowed_to?(:edit_wiki_pages, project)
      end
      return false
    end

    def permission_to_read_file(user, project, container_type)
      case container_type
        when "Project"
          then return user.allowed_to?(:view_files, project)
        when "Issue"
          then return user.allowed_to?(:view_issues, project)
        when "News"
          then return user.allowed_to?(:view_news, project)
        when "Document"
          then return user.allowed_to?(:view_documents, project)
        when "WikiPage"
          then return user.allowed_to?(:view_wiki_pages, project)
      end
      return false
    end

    def permission_to_add_file(user, project, container_type)
      case container_type
        when "Project"
          then return false
        when "Issue"
          then return user.allowed_to?(:edit_issues, project)
        when "News"
          then return user.allowed_to?(:manage_news, project)
        when "Document"
          then return user.allowed_to?(:add_documents, project)
        when "WikiPage"
          then return user.allowed_to?(:edit_wiki_pages, project)
      end
      return false
    end

    def get_key(attachment)
      return attachment.id.to_s + "_" + attachment.created_on.to_s.gsub(/\W+/, "_")
    end

    def go_back_url(attachment)
      return nil
    end

    def get_attachment_config(user, attachment, lang, action_data)
      ext = file_ext(attachment.disk_filename, true)
      project_is_not_readonly = attachment.project.status != 5
      permission_to_edit = (permission_to_edit_file(user, attachment.project, attachment.container_type) || user.admin) && !attachment.container_type.eql?("Project")
      permission_to_edit = permission_to_edit && project_is_not_readonly
      if attachment.container_type.eql?("Issue")
        permission_to_edit = permission_to_edit && (Issue.find(attachment.container_id).status_id != 5)
      end
      config = {
        :type => "desktop",
        :documentType => FileUtility.get_file_type(attachment.disk_filename),
        :document => {
          :title => attachment.filename,
          :url => get_download_url(attachment.id, user.id),
          :fileType => ext,
          :key => get_key(attachment),
          :permissions => {
            :edit => permission_to_edit && FileUtility.is_editable(attachment),
            :fillForms => permission_to_edit && FileUtility.is_editable(attachment) && ext.eql?("oform")
          }
        },
        :editorConfig => {
          :actionLink => action_data ? JSON.parse(action_data) : nil,
          :mode => (permission_to_edit && FileUtility.is_editable(attachment)) ? "edit" : "view",
          :lang => lang ? lang : "en",
          :callbackUrl => get_callback_url(attachment.id, user),
          :user => {
            :id => user.id.to_s,
            :name => user.lastname + " " + user.firstname
          },
          :customization => {
            :forcesave => false,
            :goback => {
              :url => go_back_url(attachment)
            },
            :chat => Setting.plugin_onlyoffice_redmine["editor_chat"].eql?("on"),
            :help => Setting.plugin_onlyoffice_redmine["editor_help"].eql?("on"),
            :feedback => Setting.plugin_onlyoffice_redmine["editor_feedback"].eql?("on"),
            :compactHeader => Setting.plugin_onlyoffice_redmine["editor_compact_header"].eql?("on"),
            :toolbarNoTabs => Setting.plugin_onlyoffice_redmine["editor_toolbar_no_tabs"].eql?("on")
          }
        }
      }
      if JwtHelper.is_enabled
        config["token"] = JwtHelper.encode(config)
      end
      return config
    end

  end
end