# Copyright (c) Ascensio System SIA 2021. All rights reserved.
# http://www.onlyoffice.com

class DocumentHelper

  @@base_url = nil
  @@editable_types = %w[application/vnd.openxmlformats-officedocument.wordprocessingml.document application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.openxmlformats-officedocument.presentationml.presentation]

  class << self

    def init (url)
      @@base_url = url
    end

    def get_download_url(id, user_id)
      payload = {
        :attachment_id => id,
        :type => "download",
        :userid => user_id
      }
      return @@base_url + "/onlyoffice/download/#{id}?key=#{JWTHelper.encode(payload, Setting.plugin_onlyoffice_redmine["onlyoffice_key"])}"
    end

    def get_callback_url(id, user)
      payload = {
        :attachment_id => id,
        :type => "callback"
      }
      url = @@base_url + "/onlyoffice/callback/#{id}/#{user.rss_key}?key=#{JWTHelper.encode(payload, Setting.plugin_onlyoffice_redmine["onlyoffice_key"])}"
    end

    def get_document_type(file_name)
      doc_type = FileUtility.get_file_type(file_name)
    end

    def file_ext(file_name)
      ext = File.extname(file_name).downcase
    end

    def permission_to_edit_file(user_roles, container_type)
      user_roles.each do |role|
        case container_type
        when "Project"
        then return false
        when "Issue"
        then return (role.permissions.include? :edit_issues)
        when "News"
        then return (role.permissions.include? :manage_news)
        when "Document"
        then return (role.permissions.include? :edit_documents)
        when "WikiPage"
        then return (role.permissions.include? :edit_wiki_pages)
        else
          return false
        end
      end
    end

    def permission_to_read_file(user_roles, container_type)
      user_roles.each do |role|
        case container_type
        when "Project"
        then return (role.permissions.include? :view_files)
        when "Issue"
        then return (role.permissions.include? :view_issues)
        when "News"
        then return (role.permissions.include? :view_news)
        when "Document"
        then return (role.permissions.include? :view_documents)
        when "WikiPage"
        then return (role.permissions.include? :view_wiki_pages)
        else
          return false
        end
      end
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
      editable = @@editable_types.include?(attachment.content_type)
      return editable
    end

    def get_attachment_config(user, attachment, lang, action_data)
      if Setting.plugin_onlyoffice_redmine["onlyoffice_key"].eql?(nil)
        Setting.plugin_onlyoffice_redmine["onlyoffice_key"] = Token.generate_token_value
      end
      permission_to_edit = permission_to_edit_file(user.roles_for_project(attachment.project), attachment.container_type)
      config = {
        :type => "desktop",
        :documentType => get_document_type(attachment.disk_filename),
        :document => {
          :title => attachment.filename,
          :url => get_download_url(attachment.id, user.id),
          :fileType => file_ext(attachment.disk_filename).delete("."),
          :key => get_key(attachment),
          :permissions => {
            :edit => permission_to_edit && is_editable(attachment) ? true : false
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
      if JWTHelper.is_enabled
        config["token"] = JWTHelper.encode(config)
      end
      return config
    end

  end
end