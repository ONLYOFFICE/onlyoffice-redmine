class OnlyofficeConvertController < OnlyofficeBaseController

    before_action :find_attachment, :file_readable, :read_authorize, :only => [ :convert_page, :convert ]

    def convert_page
        @page, back_url = get_page(params[:page_id], params[:page_type], @attachment)

        @file_name = DocumentHelper.file_name_without_ext(@attachment.filename)
        @ext = DocumentHelper.file_ext(@attachment.disk_filename, true)
        @formats = FormatUtility.format_supported(@ext)

        return render_403 unless \
          @attachment.project &&
          (@attachment.project.active? || @attachment.project.closed?) &&
          @attachment.visible?

        if @formats.empty?
          # flash[:error] = "Conversion unsupported"
          # render(layout: "base")
          return render_403
        end

        view = Views::OnlyOfficeConvert::Index.new(helpers:)
        view.input_basename = @attachment.filename
        view.input_size = helpers.number_to_human_size(@attachment.filesize)
        view.input_author = @attachment.author.to_s
        view.input_create_on = helpers.format_time(@attachment.created_on)
        view.type_name = "type"
        view.type_save_value = "_unset_"
        view.type_download_value = "download_as"
        view.input_id_name = "id"
        view.input_id_value = @attachment.id.to_s
        view.page_id_name = "page_id"
        view.page_id_value = params[:page_id].to_s
        view.page_type_name = "page_type"
        view.page_type_value = params[:page_type]
        view.output_name_name = "field_name"
        view.output_name_value = DocumentHelper.file_name_without_ext(@attachment.filename)
        view.input_type_name = "onlyoffice_convert_current_type"
        view.input_type_value = DocumentHelper.file_ext(@attachment.disk_filename, true)
        view.output_type_name = "onlyoffice_convert_end_type"
        view.output_type_options = FormatUtility.format_supported(view.input_type_value)
        view.download_url = helpers.onlyoffice_convert_path(@attachment.id, @attachment.id)

        return render(inline: view.inline, layout: "base") unless @page

        save_url = helpers.onlyoffice_convert_path(@page.id)
        view.cancel_url = back_url

        if params[:page_type] == "Document"
          allowed_to_add = User.current.allowed_to?(
            {
              controller: "documents",
              action: "add_attachment"
            },
            @attachment.project
          )
          if allowed_to_add
            view.save_url = save_url
          end
          return render(inline: view.inline, layout: "base")
        end

        if params[:page_type] == "Issue"
          issue = Issue.find(@attachment.container_id)
          if !issue.closed?
            view.save_url = save_url
          end
          return render(inline: view.inline, layout: "base")
        end

        view.save_url = save_url

        render(inline: view.inline, layout: "base")
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

        editor_base_url = Config.get_docserver_url()

        title = file_name + "." + next_type

        url = DocumentHelper.get_download_url(@attachment.id, User.current.id)
        key = DocumentHelper.get_key(@attachment)

        @@res_convert = [0, nil]

        begin
          @@res_convert = ServiceConverter.get_converted_uri(editor_base_url, title, url, current_type, next_type, key)
          if @@res_convert[0] == 100 && !@@res_convert[1].nil?
            if download_as
              response = {
                message: I18n.t("notice_successful_create"),
                url: @@res_convert[1].to_s
              }
              render(plain: response.to_json.to_s)
            else
              @page, back_page = get_page(params[:page_id], params[:page_type], @attachment)
        new_attachment = OnlyofficeConvertController.create_file(@@res_convert[1], file_name, next_type)
              @page.attachments << new_attachment
              response = {
                url: back_page.to_s
              }
              if @page.save
                response[:message] = I18n.t("notice_successful_create")
                flash[:notice] = l(:notice_successful_create)
              else
                response[:message] = I18n.t("onlyoffice_attachment_create_error")
                response[:error] = I18n.t("onlyoffice_attachment_create_error")
                flash[:error] = l(:onlyoffice_attachment_create_error)
              end
              render(plain: response.to_json.to_s)
            end
          else
            response = {
              message: nil,
              percent: @@res_convert[0].to_s
            }
            render(plain: response.to_json.to_s)
            return
          end
        rescue => ex
          logger.error(ex.full_message)
          response = {
            message: I18n.t("onlyoffice_attachment_create_error"),
            error: ex.message
          }
          render(plain: response.to_json.to_s)
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
