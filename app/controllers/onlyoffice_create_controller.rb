class OnlyofficeCreateController < ApplicationController

  before_action :find_project_by_project_id, :only => [ :new, :create ]
  before_action :valid_ext
  before_action :check_add_permissions

  def new
    @document = @project.documents.build
    @document.safe_attributes = params[:document]
  end

  def create
    @document = @project.documents.build
    @document.safe_attributes = params[:document]
    
    attachment = create_attachment_from_template_file()
    @document.attachments << attachment
    if @document.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to project_documents_path(@project)
    else
      render :action => 'new'
    end
  end

  private

  def create_attachment_from_template_file(author=User.current)
    path = Rails.root.join('plugins', 'onlyoffice_redmine', 'assets', 'document-templates', 'en-US', 'new.'+@ext)
    file = File.read(path)

    attachment = Attachment.create(:file => file, :author => author)
    attachment.filename = l("onlyoffice_create_#{@ext}")+".#{@ext}"
    attachment.content_type = FileUtility.get_mimetype(@ext)
    attachment.save
    attachment
  end

  def check_add_permissions
    if @project && @project.archived?
      @archived_project = @project
      render_403 :message => :notice_not_authorized_archived_project
    elsif DocumentHelper.permission_to_add_file(User.current, @project, "Document")
      true
    else
      deny_access
    end
  end

  def valid_ext
    @ext = params[:ext]
    if FileUtility.can_create(@ext)
      true
    else
      render_error({:status => 400})
    end
  end
end