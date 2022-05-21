class OnlyofficeConvertController < ApplicationController

    @@res_convert = [0, nil]

    def convert_page
        @page = get_page(params[:page_id], params[:page_type])
        @file_id = params[:file_id]
        @file = Attachment.find_by_id(@file_id)

        @file_name = @file.filename[0..@file.filename.index(".")-1]
        @ext = DocumentHelper.file_ext(@file.disk_filename).delete(".")
        @formats = FormatUtility.format_supported(@ext)

        render :action => 'index'
    end

    def convert
        file_name = params[:field_name]
        current_type = params[:onlyoffice_convert_current_type]
        next_type = params[:onlyoffice_convert_end_type]

        editor_base_url = Config.get_config("oo_address")
        secret = Config.get_config("jwtsecret")

        attachment = Attachment.find_by_id(params[:file_id])
        title = file_name + "." + next_type

        url = send("download_named_attachment_url", attachment, attachment.filename)
        key = DocumentHelper.get_key(attachment)

        begin
          @@res_convert = ServiceConverter.get_converted_uri(editor_base_url, title, url.to_s, current_type, next_type, key, 'secret')
          if @@res_convert[0] == 100 && !@@res_convert[1].nil?
            if params[:type].eql?('download_as')
              redirect_to @@res_convert[1]
            else
              @page = get_page(params[:page_id], params[:page_type])
              attachment = OnlyofficeConvertController.crete_file(@@res_convert[1], title, next_type)
              @page.attachments << attachment
              if @page.save
                flash[:notice] = l(:notice_successful_create)
              else
                flash[:error] = l(:onlyoffice_attachment_create_error)
              end
              redirect_to params[:back_page]
            end
          else
            render plain: '{ "percent": "' + @@res_convert[0].to_s + '"}'
            return
          end
        rescue => ex
          logger.error(ex.full_message)
          render plain: '{ "error": "' + ex.message + '"}'
          return
        end
    end

    def get_page(page_id, type)
        case type
            when "File"
                return Project.find(page_id)
            when "News"
                return News.find(page_id)
            when "Issue"
                return Issue.find(page_id)
            when "WikiPage"
                return WikiPage.find(page_id)
            when "Document"
                return Document.find(page_id)
        end
    end

    class << self

        def crete_file(url = nil, file_name, ext)
            if !url.nil?
              res = CallbackHelper.do_request(url)
              data = res.body

              if data.nil?
                raise 'stream is null'
              end
            end
            path = url.nil? ? Rails.root.join('plugins', 'onlyoffice_redmine', 'assets', 'document-templates', 'en-US', 'new.docx') : url
            file = url.nil? ? File.open(path, "rb") { |file| file.read } : open(url, "rb").read
            attachment = Attachment.create(:file => file, :author => User.current)
            attachment.filename = file_name
            attachment.content_type = FileUtility.get_mimetype(ext)
            attachment.save
            return attachment
        end

    end
end
