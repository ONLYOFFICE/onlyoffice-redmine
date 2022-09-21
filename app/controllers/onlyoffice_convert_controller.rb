class OnlyofficeConvertController < ApplicationController

    @@res_convert = [0, nil]

    def convert_page
        @file_id = params[:file_id]
        @file = Attachment.find_by_id(@file_id)
        @page, back_url = get_page(params[:page_id], params[:page_type], @file)

        @file_name = DocumentHelper.file_name_without_ext(@file.filename)
        @ext = DocumentHelper.file_ext(@file.disk_filename, true)
        @formats = FormatUtility.format_supported(@ext)

        render :action => 'index'
    end

    def convert
        JwtHelper.init
        DocumentHelper.init(request.base_url)

        file_name = params[:field_name]
        current_type = params[:onlyoffice_convert_current_type]
        next_type = params[:onlyoffice_convert_end_type]

        editor_base_url = Config.get_config("oo_address")

        attachment = Attachment.find_by_id(params[:file_id])
        title = file_name + "." + next_type

        url = DocumentHelper.get_download_url(attachment.id, User.current.id)
        key = DocumentHelper.get_key(attachment)

        begin
          @@res_convert = ServiceConverter.get_converted_uri(editor_base_url, title, url, current_type, next_type, key)
          if @@res_convert[0] == 100 && !@@res_convert[1].nil?
            if params[:type].eql?('download_as')
              render plain: '{ "url": "' + @@res_convert[1].to_s + '" }'
            else
              @page, back_page = get_page(params[:page_id], params[:page_type], attachment)
              new_attachment = OnlyofficeConvertController.crete_file(@@res_convert[1], file_name, next_type)
              @page.attachments << new_attachment
              if @page.save
                flash[:notice] = l(:notice_successful_create)
              else
                flash[:error] = l(:onlyoffice_attachment_create_error)
              end
              render plain: '{ "url": "' + back_page.to_s + '" }'
            end
          else
            render plain: '{ "percent": "' + @@res_convert[0].to_s + '" }'
            return
          end
        rescue => ex
          logger.error(ex.full_message)
          render plain: '{ "error": "' + ex.message + '" }'
          return
        end
    end

    def get_page(page_id, type, attachment)
        case type
            when "News"
                news = News.find(page_id)
                return news, news_path(news)
            when "Issue"
                issue = Issue.find(page_id)
                return issue, issue_path(issue)
            when "WikiPage"
                wiki = WikiPage.find(page_id)
                return wiki, project_wiki_page_path(attachment.project, wiki.title)
            when "Document"
                document = Document.find(page_id)
                return document, document_path(document)
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
            file = url.nil? ? File.open(path, "rb") { |file| file.read } : URI.open(url, "rb").read
            attachment = Attachment.create(:file => file, :author => User.current)
            attachment.filename = file_name + "." + ext
            attachment.content_type = FileUtility.get_mimetype(ext)
            attachment.save
            return attachment
        end

    end
end
