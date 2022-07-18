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
  @@editable_types = %w[.docx .docxf .oform .xlsx .pptx]

  class << self

    def init (url)
      @@base_url = FileUtility.get_redmine_internal_url(url)
    end

    def get_download_url(id, user_id)
      payload = {
        :attachment_id => id,
        :type => "download",
        :userid => user_id
      }
      return @@base_url + "/onlyoffice/download/#{id}?key=#{JwtHelper.encode(payload, Setting.plugin_onlyoffice_redmine["onlyoffice_key"])}"
    end

    def get_callback_url(id, user)
      payload = {
        :attachment_id => id,
        :type => "callback"
      }
      url = @@base_url + "/onlyoffice/callback/#{id}/#{user.rss_key}?key=#{JwtHelper.encode(payload, Setting.plugin_onlyoffice_redmine["onlyoffice_key"])}"
    end

    def get_document_type(file_name)
      doc_type = FileUtility.get_file_type(file_name)
    end

    def file_ext(file_name)
      ext = File.extname(file_name).downcase
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
        when "Document"
          then return user.allowed_to?(:add_documents, project)
      end
      return false
    end

    def get_key(attachment)
      return attachment.id.to_s + "_" + attachment.created_on.to_s.gsub(/\W+/, "_")
    end

    def go_back_url(attachment)
      case attachment.container_type
      when "Project"
      then return @@base_url + "/projects/#{attachment.project}/files"
      when "Issue"
      then return @@base_url + "/issues/#{attachment.container.id}"
      when "News"
      then return @@base_url + "/news/#{attachment.container.id}"
      when "Document"
      then return @@base_url + "/documents/#{attachment.container.id}"
      when "WikiPage"
      then return @@base_url + "/projects/#{attachment.project}/wiki"
      else
        return @@base_url + "/projects/#{attachment.project}"
      end
    end

    def is_editable(attachment)
      editable = @@editable_types.include?(file_ext(attachment.disk_filename))
      return editable
    end

    def get_attachment_config(user, attachment, lang, action_data)
      if Setting.plugin_onlyoffice_redmine["onlyoffice_key"].eql?(nil)
        Setting.plugin_onlyoffice_redmine["onlyoffice_key"] = Token.generate_token_value
      end
      ext = file_ext(attachment.disk_filename).delete(".")
      project_is_not_readonly = attachment.project.status != 5
      permission_to_edit = (permission_to_edit_file(user, attachment.project, attachment.container_type) || user.admin) && !attachment.container_type.eql?("Project")
      permission_to_edit = permission_to_edit && project_is_not_readonly
      if attachment.container_type.eql?("Issue")
        permission_to_edit = permission_to_edit && (Issue.find(attachment.container_id).status_id != 5)
      end
      config = {
        :type => "desktop",
        :documentType => get_document_type(attachment.disk_filename),
        :document => {
          :title => attachment.filename,
          :url => get_download_url(attachment.id, user.id),
          :fileType => ext,
          :key => get_key(attachment),
          :permissions => {
            :edit => permission_to_edit && is_editable(attachment) ? true : false,
            :fillForms => permission_to_edit && is_editable(attachment) && ext.eql?("oform") ? true : false
          }
        },
        :editorConfig => {
          :actionLink => action_data ? JSON.parse(action_data) : nil,
          :mode => permission_to_edit.eql?(true) && is_editable(attachment) ? "edit" : "view",
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
            :chat => Setting.plugin_onlyoffice_redmine["editor_chat"].eql?("on") ? true : false,
            :help => Setting.plugin_onlyoffice_redmine["editor_help"].eql?("on") ? true : false,
            :feedback => Setting.plugin_onlyoffice_redmine["editor_feedback"].eql?("on") ? true : false,
            :compactHeader => Setting.plugin_onlyoffice_redmine["editor_compact_header"].eql?("on") ? true : false,
            :toolbarNoTabs => Setting.plugin_onlyoffice_redmine["editor_toolbar_no_tabs"].eql?("on") ? true : false
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