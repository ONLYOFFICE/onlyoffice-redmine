# Copyright (c) Ascensio System SIA 2021. All rights reserved.
# http://www.onlyoffice.com

require_dependency "attachment"
require_dependency "user"

class OnlyofficeController < AccountController

  skip_before_action :verify_authenticity_token, :only => [ :callback ]
  before_action :find_attachment, :only => [ :download, :editor]
  before_action :file_readable, :read_authorize, :only => [ :download, :editor ]

  def download
    # check if request came from Docs

    send_file @attachment.diskfile, :filename => @attachment.filename,
                                    :type => detect_content_type(@attachment),
                                    :disposition => "attachment"
  end

  def editor
    DocumentHelper.init(request.base_url)
    @user = User.current
    @editor_config = DocumentHelper.get_attachment_config(@user, @attachment, I18n.locale,  params[:action_data])
  end

  def callback
    data = CallbackHelper.read_body(request)
    if data == nil || data.empty?
      render plain: '{"error":1, "message": "Callback data in null or empty"}'
      return
    end

    user_by_rss = User.find_by_rss_key(params[:rss])
    userid = nil
    if data.has_key?("users")
      userid = data["users"].include?(user_by_rss.id.to_s) ? user_by_rss.id : nil
    end
    if userid.eql?(nil)
    actions = data["actions"]
      if actions.length > 0
        userid = actions[0]["userid"]
      end
    end

    if userid.eql?(nil)
      logger.error("Userid is null")
      render plain: '{"error":1, "message": "Userid is null"}'
      return
    end

    unless user_by_rss.eql?(User.find(userid))
      logger.error("Different users found.")
      render plain: '{"error":1, "message": "Different users found."}'
      return
    end
    self.logged_user = user_by_rss

    status = data["status"].to_i

    case status
    when 0
      logger.error "ONLYOFFICE has reported that no doc with the specified key can be found"
      render plain: '{"error":1, "message": "ONLYOFFICE has reported that no doc with the specified key can be found"}'
      return
    when 1
      logger.info "User has entered/exited ONLYOFFICE"
      render plain: '{"error":0}'
      return
    when 2
      begin
        logger.info "Document Updated, changing content"
        @attachment = Attachment.find(params[:id])
        saved = CallbackHelper.process_save(data, @attachment)
        render plain: '{"error":' + saved.to_s + '}'
      rescue => ex
        render plain: '{"error":1, "message": "' + ex.message + '"}'
      end
      return
    when 3
      logger.error "ONLYOFFICE has reported that saving the document has failed"
      render plain: '{"error":1, "message": "ONLYOFFICE has reported that saving the document has failed"}'
      return
    when 4
      logger.info "No document updates"
      render plain: '{"error":0}'
      return
    when 6
      unless Setting.plugin_onlyoffice_redmine["forcesave"].eql?("on")
        logger.info "Forcesave is disabled, ignoring forcesave request"
        render plain: '{"error":1, "message": "Forcesave is disabled, ignoring forcesave request"}'
        return nil
      end
      logger.info "Forcesave request "
      logger.info "Forcesave complete"
      return
    else
      render plain: '{"error":0}'
      return
    end
  end

  private

  def find_attachment
    @attachment = Attachment.find(params[:id])
    # Show 404 if the filename in the url is wrong
    raise ActiveRecord::RecordNotFound if params[:filename] && params[:filename] != @attachment.filename

    @project = @attachment.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Checks that the file exists and is readable
  def file_readable
    if @attachment.readable?
      true
    else
      logger.error "Cannot send attachment, #{@attachment.diskfile} does not exist or is unreadable."
      render_404
    end
  end

  def read_authorize
    @attachment.visible? ? true : deny_access
  end

  def update_authorize
    @attachment.editable? ? true : deny_access
  end

  def detect_content_type(attachment)
    content_type = attachment.content_type
    if content_type.blank? || content_type == "application/octet-stream"
      content_type =
        Redmine::MimeType.of(attachment.filename).presence ||
        "application/octet-stream"
    end

    content_type
  end

end