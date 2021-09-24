# Copyright (c) Ascensio System SIA 2021. All rights reserved.
# http://www.onlyoffice.com

class DocumentHelper

  @@base_url = nil
  @@editable_types = "application/vnd.openxmlformats-officedocument.wordprocessingml.document|
                        application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|
                        application/vnd.openxmlformats-officedocument.presentationml.presentation"

  class << self

    def init (url)
      @@base_url = url
    end

    def storage_path(attachment, filename)
      directory = attachment.diskfile.sub(attachment.disk_filename, "")
      return directory + File.basename(filename)
    end

    def history_path(path)
      directory = "#{path}-history"
      unless File.directory?(directory)
        FileUtils.mkdir_p(directory)
      end
      return directory
    end

    def version_path(history_path, version)
      return File.join(history_path, version)
    end

    def get_attachment_version(history_path, save_type)
      if !Dir.exist?(history_path)
        return 1.0
      end

      version = 1.0
      Dir.foreach(history_path) { |e|
        next if e.eql?(".")
        next if e.eql?("..")
        if File.directory?(File.join(history_path, e))
          if e.to_f >= version
            version = save_type.eql?("force") ? e.to_f + 0.1 : e.to_i + 1.0
          end
        end
      }
      return version
    end

    def get_download_url(id)
      return @@base_url + "/onlyoffice/download/#{id}"
    end

    def get_callback_url(id, user)
      url = @@base_url + "/onlyoffice/callback/#{id}/#{user.rss_key}"
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

    def get_key(attachment)
      return attachment.disk_filename + "_" + get_attachment_version(history_path(attachment.diskfile), "save").to_s
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
      editable_mime_types = @@editable_types.split("|")
      editable = editable_mime_types.include?(attachment.content_type)
      return editable
    end

    def get_attachment_config(user, attachment, lang, action_data)
      permission_to_edit = permission_to_edit_file(user.roles_for_project(attachment.project), attachment.container_type)
      config = {
        :type => "desktop",
        :documentType => get_document_type(attachment.disk_filename),
        :document => {
          :title => attachment.filename,
          :url => get_download_url(attachment.id),
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