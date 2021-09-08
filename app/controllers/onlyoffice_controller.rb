require_dependency "attachment"

class OnlyofficeController < ApplicationController
  
  before_action :find_attachment, :only => [ :download ]
  before_action :file_readable, :read_authorize, :only => [ :download ]

  def download
    # check if request came from Docs

    send_file @attachment.diskfile, :filename => @attachment.filename,
                                    :type => detect_content_type(@attachment),
                                    :disposition => "attachment"
  end

  def editor
    render plain: "editor"
  end

  def callback
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