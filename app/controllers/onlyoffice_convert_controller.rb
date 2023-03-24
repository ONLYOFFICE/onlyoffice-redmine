class OnlyofficeConvertController < OnlyofficeBaseController

    before_action :find_attachment, :file_readable, :read_authorize, :only => [ :convert_page, :convert ]

    def convert_page
        @page, back_url = get_page(params[:page_id], params[:page_type], @attachment)

        @file_name = DocumentHelper.file_name_without_ext(@attachment.filename)
        @ext = DocumentHelper.file_ext(@attachment.disk_filename, true)
        @formats = FormatUtility.format_supported(@ext)

        render :action => 'index'
    end

    def convert
        JwtHelper.init
        DocumentHelper.init(request.base_url)

        download_as = params[:type].eql?('download_as')

        if !download_as
          check_add_permissions(params[:page_type])
        end

        file_name = params[:field_name]
        current_type = params[:onlyoffice_convert_current_type]
        next_type = params[:onlyoffice_convert_end_type]

        editor_base_url = Config.get_config("oo_address")

        title = file_name + "." + next_type

        url = DocumentHelper.get_download_url(@attachment.id, User.current.id)
        key = DocumentHelper.get_key(@attachment)

        @@res_convert = [0, nil]

        begin
          @@res_convert = ServiceConverter.get_converted_uri(editor_base_url, title, url, current_type, next_type, key)
          if @@res_convert[0] == 100 && !@@res_convert[1].nil?
            if download_as
              render plain: '{ "url": "' + @@res_convert[1].to_s + '" }'
            else
              @page, back_page = get_page(params[:page_id], params[:page_type], @attachment)
        new_attachment = OnlyofficeConvertController.create_file(@@res_convert[1], file_name, next_type)
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

    def create_file(url = nil, file_name, ext)
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

    private

    def check_add_permissions(page_type)
      if @project && @project.archived?
        @archived_project = @project
        render_403 :message => :notice_not_authorized_archived_project
      elsif DocumentHelper.permission_to_add_file(User.current, @project, page_type)
        true
      else
        deny_access
      end
    end
end
