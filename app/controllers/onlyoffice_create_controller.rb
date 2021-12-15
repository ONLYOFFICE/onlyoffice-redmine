class OnlyofficeCreateController < ApplicationController

  before_action :find_project_by_project_id, :only => [ :new, :create, :new_doc_attachment ]
  before_action :valid_ext, :only => [ :new, :create]
  before_action :check_add_permissions
  before_action :valid_doc_type, :only => [:new_doc_attachment]

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

  def new_doc_attachment
    @document = Document.find(params[:document_id])

    attachment = create_attachment_from_template_file()
    @document.attachments << attachment
    if @document.save
      flash[:notice] = l(:notice_successful_create)
    else
      flash[:error] = l(:onlyoffice_attachment_create_error)
    end
    redirect_to document_path(@document)
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

  def valid_ext(ext = nil)
    @ext = ext.eql?(nil) ? params[:ext] : ext
    if !ext.eql?("") && FileUtility.can_create(@ext)
      true
    else
      render_error({:status => 400})
    end
  end

  def valid_doc_type
    docType = params[:docType]
    ext = ""
    case docType
    when l(:onlyoffice_create_docx)
      then ext = "docx"
    when l(:onlyoffice_create_xlsx)
      then ext = "xlsx"
    when l(:onlyoffice_create_pptx)
      then ext = "pptx"
    when l(:onlyoffice_create_docxf)
      then ext = "docxf"
    end
    valid_ext(ext)
  end
end