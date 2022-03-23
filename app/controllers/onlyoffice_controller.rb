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

class OnlyofficeController < AccountController

  skip_before_action :verify_authenticity_token, :only => [ :callback ]
  before_action :find_attachment, :only => [ :download, :editor, :callback, :save_as ]
  before_action :file_readable, :read_authorize, :only => [ :editor ]

  def self.detect_content_type(attachment)
    content_type = attachment.content_type
    if content_type.blank? || content_type == "application/octet-stream"
      content_type =
        Redmine::MimeType.of(attachment.filename).presence ||
        "application/octet-stream"
    end

    content_type
  end

  def check_settings
    render plain: is_valid_setings(params[:url], params[:secret])
  end

  def download
    file_readable
    if params[:key].eql?(nil)
      logger.error("No key param in url")
      render_403
    end

    attachment_id = JSON.parse(JWTHelper.decode(params[:key], Setting.plugin_onlyoffice_redmine["onlyoffice_key"]))["attachment_id"]
    type = JSON.parse(JWTHelper.decode(params[:key], Setting.plugin_onlyoffice_redmine["onlyoffice_key"]))["type"]
    user_id = JSON.parse(JWTHelper.decode(params[:key], Setting.plugin_onlyoffice_redmine["onlyoffice_key"]))["userid"]

    user = User.find(user_id)
    read_authorize(user)
    perm_to_read = DocumentHelper.permission_to_read_file(user, @attachment.project, @attachment.container_type)
    if !perm_to_read
      logger.error("No permission to download file")
      render_403
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

  def editor
    JWTHelper.init
    DocumentHelper.init(request.base_url)
    @user = User.current
    @editor_config = DocumentHelper.get_attachment_config(@user, @attachment, I18n.locale,  params[:action_data])
    case @editor_config[:document][:fileType]
    when 'docxf', 'oform'
      @favicon = @editor_config[:document][:fileType]
    else
      @favicon = @editor_config[:documentType]
    end
  end

  def callback
    if params[:key].eql?(nil)
      logger.error("No key param in url")
      render_403
    end

    type = JSON.parse(JWTHelper.decode(params[:key], Setting.plugin_onlyoffice_redmine["onlyoffice_key"]))["type"]
    attachment_id = JSON.parse(JWTHelper.decode(params[:key], Setting.plugin_onlyoffice_redmine["onlyoffice_key"]))["attachment_id"]

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

  def read_authorize(user=User.current)
    @attachment.visible?(user) ? true : deny_access
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

  def is_valid_setings(url, secret = nil)
    editor_base_url = url
    is_command = ""

    attachment = OnlyofficeConvertController.crete_file(nil, "OnlyOfficeCheakConvertService.docx", "docx")
    url_file = send("download_named_attachment_url", attachment, attachment.filename)

    path = url_file.to_s
    key = ServiceConverter.generate_revision_id(path)
    is_convert = 0

    begin
      res_health = CallbackHelper.do_request(editor_base_url + "healthcheck")
      res_command = CallbackHelper.command_request("version",  nil, editor_base_url, secret)
      is_command += res_command["version"]

      res_convert = ServiceConverter.get_converted_uri(editor_base_url, nil, path, "docx", "pdf", key, false, nil, nil, secret)
      is_convert = res_convert[0]
    rescue
      return false
    end

    if is_command.empty? || is_convert != 100
      return false
    end

    return true
  end

end