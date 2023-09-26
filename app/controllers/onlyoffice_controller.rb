#
# (c) Copyright Ascensio System SIA 2022
# http://www.onlyoffice.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_dependency "attachment"
require_dependency "user"

class OnlyofficeController < OnlyofficeBaseController

  skip_before_action :verify_authenticity_token, :only => [ :callback ]
  before_action :find_attachment, :only => [ :download, :editor, :callback, :save_as ]
  before_action :file_readable, :read_authorize, :only => [ :editor ]

  class << self

    def checking_activity_onlyoffice
      url = Config.get_docserver_url
      return !url.nil? && !url.empty?
    end

  end

  def download
    file_readable
    if params[:key].eql?(nil)
      logger.error("No key param in url")
      render_403
    return
    end

  jwt_body = JSON.parse(JwtHelper.decode(params[:key], Setting.plugin_onlyoffice_redmine["onlyoffice_key"]))
  attachment_id = jwt_body["attachment_id"]
  type = jwt_body["type"]
  user_id = jwt_body["userid"]

    user = User.find(user_id)
    read_authorize(user)
    perm_to_read = DocumentHelper.permission_to_read_file(user, @attachment.project, @attachment.container_type)
    if !perm_to_read
      logger.error("No permission to download file")
      render_403
    return
  end

  if JwtHelper.is_enabled
    jwtHeader = JwtHelper.jwt_header
    jwtValue = request.headers[jwtHeader]
    if !jwtValue
    logger.error("Download without JWT")
    render_403
    return
    end

    jwtValue.slice!(0, "Bearer ".length)
    token = JwtHelper.decode(jwtValue)

    if !token || token.eql?("")
    raise "Invalid JWT signature"
    end
    end

    if @attachment.id.eql?(attachment_id) && type.eql?("download")
      send_file @attachment.diskfile, :filename => @attachment.filename,
                :type => detect_content_type(@attachment),
                :disposition => "attachment"
    else
      logger.error("Different attachments id from token and url.")
      render_404
    end

  end

  def download_test
    if JwtHelper.is_enabled
      jwtHeader = JwtHelper.jwt_header
      jwtValue = request.headers[jwtHeader]

      if !jwtValue
        logger.error("Download without JWT")
        render_403
        return
      end

      jwtValue.slice!(0, "Bearer ".length)
      token = JwtHelper.decode(jwtValue)

      if !token || token.eql?("")
        raise "Invalid JWT signature"
      end
    end

    send_data("123", :filename => "test-convert.txt", :type => "text/plain", :disposition => "attachment")
  end

  def editor
    JwtHelper.init
    DocumentHelper.init(request.base_url)
    @user = User.current
    @editor_config = DocumentHelper.get_attachment_config(@user, @attachment, I18n.locale,  params[:action_data])
    @editor_config[:editorConfig][:customization][:goback][:url] = go_back_url(@attachment)
    case @editor_config[:document][:fileType]
    when 'docxf', 'oform'
      @favicon = @editor_config[:document][:fileType]
    else
      @favicon = @editor_config[:documentType]
    end

    if Config.is_demo_ended
      flash[:error] = I18n.t("onlyoffice_editor_trial_period_ended")
      render(layout: "base")
      return
    end

    version_response = CallbackHelper.command_request("version", nil)
    version = version_response["version"]
    major = Integer(version.split(".")[0])
    fillable_unsupported = \
      (
        @editor_config[:document][:fileType] == "docxf" ||
        @editor_config[:document][:fileType] == "oform"
      ) &&
      major < 7
    if fillable_unsupported
      flash[:error] = I18n.t("onlyoffice_editor_forms_error_version")
      render(layout: "base")
      return
    end

    view = Views::OnlyOffice::Editor.new(helpers:)
    view.document_server_api_url = "#{Config.get_docserver_url(false)}web-apps/apps/api/documents/api.js"
    view.document_server_config = @editor_config.to_json
    view.save_as_url = helpers.onlyoffice_save_as_path(@attachment.id)
    view.format = @favicon
    view.basename = @attachment.filename

    render(inline: view.inline, layout: "base")
  end

  def go_back_url(attachment)
    if !attachment.container
      return nil
    end

    case attachment.container
    when Message
      url_for(attachment.container.event_url)
    when Project
      project_files_url(attachment.container)
    when Version
      project_files_url(attachment.container.project)
    when WikiPage
      project_wiki_page_url attachment.container.wiki.project, attachment.container.title
    else
      url_for(attachment.container)
    end
  end

  def callback
    if params[:key].eql?(nil)
      logger.error("No key param in url")
      render_403
    end

  jwt_body = JSON.parse(JwtHelper.decode(params[:key], Setting.plugin_onlyoffice_redmine["onlyoffice_key"]))
  type = jwt_body["type"]
  attachment_id = jwt_body["attachment_id"]

    if !type.eql?("callback")
      logger.error("Not callback token type.")
      render plain: '{"error":1, "message": "Not callback token type."}'
      return
    end

    if !@attachment.id.eql?(attachment_id)
      logger.error("Different attachments id from token and url.")
      render plain: '{"error":1, "message": "Different attachments id from token and url."}'
      return
    end

  data = CallbackHelper.read_body(request)
    if data == nil || data.empty?
      render plain: '{"error":1, "message": "Callback data is null or empty"}'
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
        logger.error(ex.full_message)
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
        return
      end
      logger.info "Forcesave request "
      logger.info "Forcesave complete"
      return
    else
      render plain: '{"error":0}'
      return
    end
  end

  def save_as
    edit_permission = DocumentHelper.permission_to_edit_file(User.current, @attachment.project, @attachment.container_type)
    permission_for_files_container = @attachment.container_type.eql?("Project") && User.current.allowed_to?(:manage_files, @attachment.project)
    if edit_permission || permission_for_files_container
      true
    else
      deny_access
      return
    end

    res = CallbackHelper.do_request(params[:url])

    new_attachment = Attachment.new(:file => res.body)
    new_attachment.author = User.current
    new_attachment.filename = params[:title]
    new_attachment.content_type = res.content_type

    new_attachment.container_id = @attachment.container_id
    new_attachment.container_type = @attachment.container_type
    
    saved = new_attachment.save
    render plain: saved
    return
  end

  private

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