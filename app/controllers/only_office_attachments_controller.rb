#
# (c) Copyright Ascensio System SIA 2023
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

# typed: true
# frozen_string_literal: true

class OnlyOfficeAttachmentsController < ApplicationController
  extend T::Sig
  extend OnlyOfficePluginHelper::Injection
  extend OnlyOfficeViewHelper::Injection

  # ```http
  # GET /attachments/{{attachment_id}}
  # Accept: text/html
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  #
  # [Redmine Reference](https://github.com/redmine/redmine/blob/5.0.0/app/controllers/attachments_controller.rb#L38)
  sig { params(helpers: T.untyped, attachment: ::Attachment).returns(String) }
  def self.show_attachment(helpers, attachment)
    unless onlyoffice_plugin_available?
      return ""
    end

    user = OnlyOfficeRedmine::User.current

    view = Views::Attachments::Show.new(helpers:)

    block = setup_link_to_attachment(helpers, user, attachment)
    unless block.sense?
      return ""
    end

    view.view_url = block.view_url
    view.edit_url = block.edit_url
    view.convert_url = block.convert_url

    view.setup_assets
    view.inline
  end

  # ```http
  # GET /documents/{{document_id}}
  # Accept: text/html
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  #
  # [Redmine Reference](https://github.com/redmine/redmine/blob/5.0.0/app/controllers/documents_controller.rb#L49)
  sig { params(helpers: T.untyped, document: ::Document).returns(String) }
  def self.show_document(helpers, document)
    unless onlyoffice_plugin_available?
      return ""
    end

    user = OnlyOfficeRedmine::User.current
    container = OnlyOfficeRedmine::Document.new(document:)

    view = Views::Documents::Show.new(helpers:)
    view.attachments = setup_link_to_attachments(helpers, user, container)

    if container.addition_allowed?(user)
      view.new_url = helpers.onlyoffice_create_attachment_path(
        container.type,
        container.id
      )
    end

    if view.attachments.empty? || !view.new_url
      return ""
    end

    view.setup_assets
    view.inline
  end

  # ```http
  # GET /projects/{{project_id}}/files
  # Accept: text/html
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  #
  # [Redmine Reference](https://github.com/redmine/redmine/blob/5.0.0/app/controllers/files_controller.rb#L31)
  sig { params(helpers: T.untyped, containers: T.untyped).returns(String) }
  def self.files(helpers, containers)
    unless onlyoffice_plugin_available?
      return ""
    end

    user = OnlyOfficeRedmine::User.current

    view = Views::Files::Index.new(helpers:)

    containers.each do |container|
      container.attachments.each_with_index do |attachment, index|
        block = setup_link_to_attachment(helpers, user, attachment)
        unless block.sense?
          next
        end

        block.index = index
        view.attachments.append(block)
      end
    end

    if view.attachments.empty?
      return ""
    end

    view.setup_assets
    view.inline
  end

  # ```http
  # GET /issues/{{issue_id}}
  # Accept: text/html
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  #
  # [Redmine Reference](https://github.com/redmine/redmine/blob/5.0.0/app/controllers/issues_controller.rb#L95)
  sig { params(helpers: T.untyped, issue: ::Issue).returns(String) }
  def self.show_issue(helpers, issue)
    unless onlyoffice_plugin_available?
      return ""
    end

    user = OnlyOfficeRedmine::User.current
    container = OnlyOfficeRedmine::Issue.new(issue:)

    view = Views::Issues::Show.new(helpers:)

    view.attachments = setup_link_to_attachments(helpers, user, container)
    if view.attachments.empty?
      return ""
    end

    view.setup_assets
    view.inline
  end

  # ```http
  # GET /news/{{news_id}}
  # Accept: text/html
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  #
  # [Redmine Reference](https://github.com/redmine/redmine/blob/5.0.0/app/controllers/news_controller.rb#L69)
  sig { params(helpers: T.untyped, news: ::News).returns(String) }
  def self.show_new(helpers, news)
    unless onlyoffice_plugin_available?
      return ""
    end

    user = OnlyOfficeRedmine::User.current
    container = OnlyOfficeRedmine::News.new(news:)

    view = Views::News::Show.new(helpers:)

    view.attachments = setup_link_to_attachments(helpers, user, container)
    if view.attachments.empty?
      return ""
    end

    view.setup_assets
    view.inline
  end

  # ```http
  # GET /projects/{{project_id}}/wiki/{{wiki_page_title}}
  # Accept: text/html
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  #
  # [Redmine Reference](https://github.com/redmine/redmine/blob/5.0.0/app/controllers/news_controller.rb#L69)
  sig { params(helpers: T.untyped, page: ::WikiPage).returns(String) }
  def self.show_wiki_page(helpers, page)
    unless onlyoffice_plugin_available?
      return ""
    end

    user = OnlyOfficeRedmine::User.current
    container = OnlyOfficeRedmine::WikiPage.new(page:)

    view = Views::News::Show.new(helpers:)

    view.attachments = setup_link_to_attachments(helpers, user, container)
    if view.attachments.empty?
      return ""
    end

    view.setup_assets
    view.inline
  end

  class ContainerParameters < T::Struct
    prop :container_type, String
    prop :container_id,   String
  end

  class AttachmentParameters < T::Struct
    prop :attachment_id, String
  end

  class UserParameters < T::Struct
    prop :user_id, String
  end

  include OnlyOfficeErrorHelper
  include OnlyOfficePluginHelper::Regular
  include OnlyOfficeJWTHelper
  include OnlyOfficeSettingsHelper
  include OnlyOfficeRouterHelper
  include OnlyOfficeViewHelper::Regular

  before_action :require_onlyoffice_plugin
  rescue_from   OnlyOfficeRedmine::Error,  with: :handle_error

  # ```http
  # GET /onlyoffice/containers/{{container_type}}/{{container_id}}/attachments/new HTTP/1.1
  # Accept: text/html
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  def new
    user = OnlyOfficeRedmine::User.current

    params = ContainerParameters.from_hash(request.parameters)
    container = params.container
    unless container
      logger.error("The #{params.container_type} (#{params.container_id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    unless container.addition_allowed?(user)
      logger.error("User (#{user.id}) isn't allowed to add an attachment to the #{container.type} (#{container.id})")
      raise OnlyOfficeRedmine::Error.forbidden
    end

    view = Views::OnlyOffice::New.new(helpers:)
    view.error_messages = helpers.error_messages_for(container)
    view.name.name = "onlyoffice[name]"
    view.description.name = "onlyoffice[description]"

    formats = OnlyOfficeRedmine::Resources::Formats.read
    view.format.name = "onlyoffice[format]"
    view.format.options += formats.creatable.map do |format|
      Views::Option.new(label: format.file_name, value: format.name)
    end

    view.create.url = helpers.onlyoffice_create_attachment_url(
      params.container_type,
      params.container_id
    )
    view.cancel.url = container.home_url(helpers)

    render_view(view)
  end

  # TODO: add additional options to create a new attachment.
  # Allow to choose a language and if not, then take it from the I18t.
  # Allow to choose whether a new attachment should contain sample data or not.
  class CreatePayload < T::Struct
    prop :name,        String, default: ""
    prop :description, String, default: ""
    prop :language,    String, default: "en-US"
    prop :format_name, String, name: "format"
  end

  # ```http
  # POST /onlyoffice/containers/{{container_type}}/{{container_id}}/attachments/new HTTP/1.1
  # Accept: text/html
  # Content-Type: application/x-www-form-urlencoded; charset=utf-8
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  def create
    user = OnlyOfficeRedmine::User.current

    params = ContainerParameters.from_hash(request.parameters)
    container = params.container
    unless container
      logger.error("The #{params.container_type} (#{params.container_id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    unless container.addition_allowed?(user)
      logger.error("User (#{user.id}) isn't allowed to add an attachment to the #{container.type} (#{container.id})")
      raise OnlyOfficeRedmine::Error.forbidden
    end

    raw_payload = self.params["onlyoffice"].permit!.to_h
    payload = CreatePayload.from_hash(raw_payload)

    format = payload.format
    unless format && format.creatable?
      logger.error("The format (#{payload.format_name}) doesn't support creation")
      raise OnlyOfficeRedmine::Error.unsupported
    end

    attachment = payload.attachment(user, format)
    container.attachments.append(attachment)
    saved = container.save
    unless saved
      logger.error("Failed to save the #{container.type} (#{container.id}) with new attachment")
      raise OnlyOfficeRedmine::Error.internal
    end

    flash[:notice] = I18n.t("notice_successful_create")
    new_attachment = helpers.onlyoffice_new_attachment_url(
      params.container_type,
      params.container_id
    )
    redirect_to(new_attachment)
  end

  class CreatePayload
    extend T::Sig

    sig { params(hash: T.untyped, strict: T.untyped).returns(CreatePayload) }
    def self.from_hash(hash, strict = nil)
      super(hash, strict)
    end

    sig { returns(T.nilable(OnlyOffice::Resources::Format)) }
    def format
      formats = OnlyOfficeRedmine::Resources::Formats.read
      formats.all.find do |format|
        format.name == @format_name
      end
    end

    sig do
      params(user: OnlyOfficeRedmine::User, format: OnlyOffice::Resources::Format)
        .returns(::Attachment)
    end
    def attachment(user, format)
      file = self.file(format)
      filename = self.filename(format)
      content_type = format.content_type
      description = @description
      Attachment.create(
        file:,
        author: user.internal,
        content_type:,
        filename:,
        description:
      )
    end

    sig { params(format: OnlyOffice::Resources::Format).returns(String) }
    def file(format)
      file = OnlyOffice::Resources::Templates.file(@language, format.name)
      File.binread(file)
    end

    sig { params(format: OnlyOffice::Resources::Format).returns(String) }
    def filename(format)
      name =
        if @name == ""
          format.file_name
        else
          @name
        end
      "#{name}#{format.extension}"
    end
  end

  # ```http
  # GET /onlyoffice/attachments/:attachment_id/view HTTP/1.1
  # Accept: text/html
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  def view
    user = OnlyOfficeRedmine::User.current

    params = AttachmentParameters.from_hash(request.parameters)
    attachment = params.attachment
    unless attachment
      logger.error("The attachment (#{params.attachment_id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    unless attachment.viewable?(user)
      logger.error("User (#{user.id}) isn't allowed to view the attachment (#{attachment.id})")
      raise OnlyOfficeRedmine::Error.forbidden
    end

    editor(attachment, user, "view")
  end

  # ```http
  # GET /onlyoffice/attachments/:attachment_id/edit HTTP/1.1
  # Accept: text/html
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  def edit
    user = OnlyOfficeRedmine::User.current

    params = AttachmentParameters.from_hash(request.parameters)
    attachment = params.attachment
    unless attachment
      logger.error("The attachment (#{params.attachment_id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    unless attachment.editable?(user)
      logger.error("User (#{user.id}) isn't allowed to edit the attachment (#{attachment.id})")
      raise OnlyOfficeRedmine::Error.forbidden
    end

    editor(attachment, user, "edit")
  end

  sig do
    params(
      attachment: OnlyOfficeRedmine::Attachment,
      user: OnlyOfficeRedmine::User,
      mode: String
    )
      .returns(T.untyped)
  end
  private def editor(attachment, user, mode)
    container = attachment.container
    unless container
      logger.error("The container for the attachment (#{attachment.id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    format = attachment.format
    unless format
      logger.error("The format (#{attachment.extension}) doesn't supported")
      raise OnlyOfficeRedmine::Error.unsupported
    end

    settings = OnlyOfficeRedmine::Settings.current
    settings.plugin.url = helpers.home_url

    attachment_payload = OnlyOfficeRouterHelper::AttachmentPayload.new(user_id: user.id)

    download_url = onlyoffice_download_attachment_url(attachment.id, attachment_payload)
    download_url = settings.plugin.resolve_internal_url(download_url)

    callback_url = onlyoffice_callback_attachment_url(attachment.id, attachment_payload)
    callback_url = settings.plugin.resolve_internal_url(callback_url)

    a = OnlyOffice::APP::Config.new(
      document: OnlyOffice::APP::Config::Document.new(
        url: download_url
      ),
      editor_config: OnlyOffice::APP::Config::EditorConfig.new(
        callback_url:,
        mode:
      )
    )
    b = container.app_config(helpers)
    c = settings.app_config
    d = attachment.app_config(user)
    e = user.app_config

    # TODO: move merging to the library.
    f =
      a
      .serialize
      .deep_merge(b.serialize)
      .deep_merge(c.serialize)
      .deep_merge(d.serialize)
      .deep_merge(e.serialize)

    encoder = jwt_encoder(settings)

    view = Views::OnlyOffice::Editor.new(helpers:)
    view.document_server_api_base_url = settings.document_server.url
    view.document_server_config = jwt_encode_payload(f, &encoder)
    view.save_as_url = helpers.onlyoffice_save_as_attachment_path(attachment.id)
    view.format = format.type
    view.basename = attachment.filename

    render_view(view)
  end

  skip_before_action :verify_authenticity_token, only: [:download]
  before_action      :verify_jwt_token,          only: [:download]

  # ```http
  # GET /onlyoffice/attachments/:attachment_id/download?user_id={{user_id}}
  # Accept: text/*
  # Host: {{plugin_internal_url}}
  # {{jwt_http_header}}: Bearer {{jwt_token}}
  # ```
  def download
    attachment_params = AttachmentParameters.from_hash(request.parameters)
    attachment = attachment_params.attachment
    unless attachment
      logger.error("The attachment (#{attachment_params.attachment_id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    user_params = UserParameters.from_hash(request.parameters)
    user = user_params.user
    unless user
      logger.error("The user (#{user_params.user_id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    unless attachment.viewable?(user)
      logger.error("User (#{user.id}) isn't allowed to view the attachment (#{attachment.id})")
      raise OnlyOfficeRedmine::Error.forbidden
    end

    format = attachment.format
    unless format
      logger.error("The format (#{attachment.extension}) doesn't supported")
      raise OnlyOfficeRedmine::Error.unsupported
    end

    send_file(
      attachment.diskfile,
      filename: attachment.filename,
      type: format.content_type,
      disposition: "attachment"
    )
  end

  # ```http
  # GET /onlyoffice/attachments/:attachment_id/convert HTTP/1.1
  # Accept: text/html
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  def convert
    user = OnlyOfficeRedmine::User.current

    params = AttachmentParameters.from_hash(request.parameters)
    attachment = params.attachment
    unless attachment
      logger.error("The attachment (#{params.attachment_id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    unless attachment.convertible?(user)
      logger.error("User (#{user.id}) isn't allowed to convert the attachment (#{attachment.id})")
      raise OnlyOfficeRedmine::Error.forbidden
    end

    container = attachment.container
    unless container
      logger.error("The container for the attachment (#{attachment.id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    format = attachment.format
    unless format
      logger.error("The format (#{attachment.extension}) doesn't supported")
      raise OnlyOfficeRedmine::Error.unsupported
    end

    view = Views::OnlyOffice::Convert.new(helpers:)

    view.attachment.basename = attachment.filename
    view.attachment.size = helpers.number_to_human_size(attachment.filesize)
    view.attachment.author = attachment.author.internal.to_s
    view.attachment.create_on = helpers.format_time(attachment.created_on)

    view.attachment.name.name = "onlyoffice[name]"
    view.attachment.name.value = attachment.name

    view.attachment.description.name = "onlyoffice[description]"
    view.attachment.description.value = attachment.description

    view.attachment.from.name = "onlyoffice[from]"
    view.attachment.from.value = format.name

    view.attachment.to.name = "onlyoffice[to]"
    view.attachment.to.options += attachment.convertible_to.map do |name|
      Views::Option.new(label: name, value: name)
    end

    if container.addition_allowed?(user)
      save = view.save || Views::Action.new
      save.url = helpers.onlyoffice_save_as_attachment_url(attachment.id)
      view.save = save
    else
      view.save = nil
    end

    view.download.url = helpers.onlyoffice_download_as_attachment_url(attachment.id)
    view.cancel.url = container.home_url(helpers)

    render_view(view)
  end

  class DoAsPayload < T::Struct
    prop :name,        String, default: ""
    prop :description, String, default: ""
    prop :from_name,   String, name: "from"
    prop :to_name,     String, name: "to"
  end

  # ```http
  # POST /onlyoffice/attachments/:attachment_id/save-as HTTP/1.1
  # Accept: text/html, application/json
  # Content-Type: application/x-www-form-urlencoded; charset=utf-8
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  def save_as
    user = OnlyOfficeRedmine::User.current

    params = AttachmentParameters.from_hash(request.parameters)
    attachment = params.attachment
    unless attachment
      logger.error("The attachment (#{params.attachment_id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    unless attachment.viewable?(user)
      logger.error("User (#{user.id}) isn't allowed to view the attachment (#{attachment.id})")
      raise OnlyOfficeRedmine::Error.forbidden
    end

    container = attachment.container
    unless container
      logger.error("The container for the attachment (#{attachment.id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    unless container.addition_allowed?(user)
      logger.error("User (#{user.id}) isn't allowed to add an attachment to the #{container.type} (#{container.id})")
      raise OnlyOfficeRedmine::Error.forbidden
    end

    raw_payload = self.params["onlyoffice"].permit!.to_h
    payload = DoAsPayload.from_hash(raw_payload)

    from = payload.from
    unless from
      logger.error("The format (#{payload.from_name}) doesn't supported")
      raise OnlyOfficeRedmine::Error.unsupported
    end

    to = payload.to
    unless to
      logger.error("The format (#{payload.to_name}) doesn't supported")
      raise OnlyOfficeRedmine::Error.unsupported
    end

    settings = OnlyOfficeRedmine::Settings.current
    settings.plugin.url = helpers.home_url

    attachment_payload = OnlyOfficeRouterHelper::AttachmentPayload.new(user_id: user.id)

    download_url = onlyoffice_download_attachment_url(attachment.id, attachment_payload)
    download_url = settings.plugin.resolve_internal_url(download_url)

    client = settings.client
    http = client.http
    http.open_timeout = 5
    http.read_timeout = settings.conversion.timeout / 1000
    client = OnlyOffice::API::Client.new(base_url: client.base_url, http:)

    conversion = OnlyOffice::API::Conversion.new(
      async: true,
      filetype: from.name,
      key: attachment.token,
      outputtype: to.name,
      region: I18n.locale.to_s,
      url: download_url
    )
    result, response = client.conversion.convert(conversion)

    begin
      case result
      when OnlyOffice::API::ConversionError
        logger.error("#{result.description} (#{response.code} #{response.message})")
        raise OnlyOfficeRedmine::Error.internal
      when OnlyOffice::API::ConversionProgress
        self.response.add_header("Cache-Control", "no-cache, no-store")
        return render(json: result.serialize)
      when OnlyOffice::API::ConversionComplete
        file_uri = URI(result.file_url)
        file = T.unsafe(file_uri).open(ssl_verify_mode: settings.ssl.verify_mode)

        attachment = Attachment.create(
          file:,
          author: user.internal,
          content_type: to.content_type,
          filename: "#{payload.name}#{to.extension}",
          description: payload.description
        )

        container.attachments.append(attachment)
        saved = container.save
        unless saved
          logger.error("Failed to save the #{container.type} (#{container.id}) with new attachment")
          raise OnlyOfficeRedmine::Error.internal
        end

        flash[:notice] = I18n.t("notice_successful_create")
      else
        # nothing
      end
    rescue OnlyOfficeRedmine::Error
      flash[:error] = I18n.t("onlyoffice_attachment_create_error")
    end

    home = container.home_path(helpers)
    redirect_to(home)
  end

  # ```http
  # POST /onlyoffice/attachments/:attachment_id/download-as HTTP/1.1
  # Accept: text/*, application/json
  # Content-Type: application/x-www-form-urlencoded; charset=utf-8
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  def download_as
    user = OnlyOfficeRedmine::User.current

    params = AttachmentParameters.from_hash(request.parameters)
    attachment = params.attachment
    unless attachment
      logger.error("The attachment (#{params.attachment_id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    unless attachment.viewable?(user)
      logger.error("User (#{user.id}) isn't allowed to view the attachment (#{attachment.id})")
      raise OnlyOfficeRedmine::Error.forbidden
    end

    container = attachment.container
    unless container
      logger.error("The container for the attachment (#{attachment.id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    raw_payload = self.params["onlyoffice"].permit!.to_h
    payload = DoAsPayload.from_hash(raw_payload)

    from = payload.from
    unless from
      logger.error("The format (#{payload.from_name}) doesn't supported")
      raise OnlyOfficeRedmine::Error.unsupported
    end

    to = payload.to
    unless to
      logger.error("The format (#{payload.to_name}) doesn't supported")
      raise OnlyOfficeRedmine::Error.unsupported
    end

    settings = OnlyOfficeRedmine::Settings.current
    settings.plugin.url = helpers.home_url

    attachment_payload = OnlyOfficeRouterHelper::AttachmentPayload.new(user_id: user.id)

    download_url = onlyoffice_download_attachment_url(attachment.id, attachment_payload)
    download_url = settings.plugin.resolve_internal_url(download_url)

    client = settings.client
    http = client.http
    http.open_timeout = 5
    http.read_timeout = settings.conversion.timeout / 1000
    client = OnlyOffice::API::Client.new(base_url: client.base_url, http:)

    conversion = OnlyOffice::API::Conversion.new(
      async: true,
      filetype: from.name,
      key: attachment.token,
      outputtype: to.name,
      region: I18n.locale.to_s,
      url: download_url
    )
    result, response = client.conversion.convert(conversion)

    begin
      case result
      when OnlyOffice::API::ConversionError
        logger.error("#{result.description} (#{response.code} #{response.message})")
        raise OnlyOfficeRedmine::Error.internal
      when OnlyOffice::API::ConversionProgress
        self.response.add_header("Cache-Control", "no-cache, no-store")
        return render(json: result.serialize)
      when OnlyOffice::API::ConversionComplete
        file_url = settings.document_server.resolve_url(result.file_url)
        flash[:notice] = I18n.t("notice_successful_create")
        return render(json: { url: file_url })
      else
        # nothing
      end
    rescue OnlyOfficeRedmine::Error
      flash[:error] = I18n.t("onlyoffice_attachment_create_error")
    end

    home = container.home_path(helpers)
    redirect_to(home)
  end

  class DoAsPayload
    extend T::Sig

    sig { params(hash: T.untyped, strict: T.untyped).returns(DoAsPayload) }
    def self.from_hash(hash, strict = nil)
      super(hash, strict)
    end

    sig { returns(T.nilable(OnlyOffice::Resources::Format)) }
    def to
      formats = OnlyOfficeRedmine::Resources::Formats.read
      formats.all.find do |format|
        format.name == @to_name
      end
    end

    sig { returns(T.nilable(OnlyOffice::Resources::Format)) }
    def from
      formats = OnlyOfficeRedmine::Resources::Formats.read
      formats.all.find do |format|
        format.name == @from_name
      end
    end
  end

  skip_before_action :verify_authenticity_token, only: [:callback]
  before_action      :verify_jwt_token,          only: [:callback]

  # ```http
  # POST /onlyoffice/attachments/{{attachment_id}}/callback?user_id={{user_id}} HTTP/1.1
  # Accept: application/json
  # Content-Type: application/json; charset=utf-8
  # Host: {{plugin_internal_url}}
  # {{jwt_http_header}}: Bearer {{jwt_token}}
  # ```
  def callback
    attachment_params = AttachmentParameters.from_hash(request.parameters)
    attachment = attachment_params.attachment
    unless attachment
      logger.error("The attachment (#{attachment_params.attachment_id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    user_params = UserParameters.from_hash(request.parameters)
    user = user_params.user
    unless user
      logger.error("The user (#{user_params.user_id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    unless attachment.editable?(user)
      logger.error("User (#{user.id}) isn't allowed to edit the attachment (#{attachment.id})")
      raise OnlyOfficeRedmine::Error.forbidden
    end

    raw_callback = request.body.read
    callback = OnlyOffice::APP::CallbackGeneric.from_hash(raw_callback)

    begin
      # rubocop:disable Lint/DuplicateBranch
      case callback
      when OnlyOffice::APP::CallbackBusy
        logger.info(callback.description)
      when OnlyOffice::APP::CallbackReady
        logger.info(callback.description)

        settings = OnlyOfficeRedmine::Settings.current
        settings.plugin.url = helpers.home_url

        url = settings.document_server.resolve_internal_url(callback.url)
        uri = URI(url)

        tempfile = T.unsafe(uri).open(ssl_verify_mode: settings.ssl.verify_mode)
        unless tempfile
          logger.error("Failed to download file (#{url}) to save")
          raise OnlyOfficeRedmine::Error.internal
        end

        # We need a copy with an ID so that we can delete files from the disk.
        current = attachment.copy({ "id" => attachment.id })

        attachment.file = ActionDispatch::Http::UploadedFile.new(
          tempfile:,
          type: attachment.content_type,
          filename: attachment.filename
        )
        attachment.files_to_final_location

        saved = attachment.save
        unless saved
          logger.error("Failed to save attachment (#{url})")
          raise OnlyOfficeRedmine::Error.internal
        end

        current.delete_from_disk
      when OnlyOffice::APP::CallbackSaveError
        logger.error(callback.description)
        raise OnlyOfficeRedmine::Error.internal
      when OnlyOffice::APP::CallbackOmitted
        logger.info(callback.description)
      when OnlyOffice::APP::CallbackSaved
        logger.info(callback.description)
      when OnlyOffice::APP::CallbackForceSaveError
        logger.error(callback.description)
        raise OnlyOfficeRedmine::Error.internal
      else
        # nothing
      end
      # rubocop:enable Lint/DuplicateBranch
    rescue OnlyOfficeRedmine::Error => error
      callback_error = OnlyOffice::APP::CallbackError.new(
        error: 1,
        message: "#{error.message}: #{callback.description}"
      )
      return render(json: callback_error.serialize)
    end

    render(json: OnlyOffice::APP::CallbackError.no_error.serialize)
  end

  class ContainerParameters
    extend T::Sig

    sig do
      params(hash: T.untyped, strict: T.untyped)
        .returns(ContainerParameters)
    end
    def self.from_hash(hash, strict = nil)
      super(hash, strict)
    end

    sig { returns(T.nilable(OnlyOfficeRedmine::Container)) }
    def container
      OnlyOfficeRedmine::GenericContainer.find(@container_id, @container_type)
    end
  end

  class AttachmentParameters
    extend T::Sig

    sig do
      params(hash: T.untyped, strict: T.untyped)
        .returns(AttachmentParameters)
    end
    def self.from_hash(hash, strict = nil)
      super(hash, strict)
    end

    sig { returns(T.nilable(OnlyOfficeRedmine::Attachment)) }
    def attachment
      id = Integer(@attachment_id, 10)
      OnlyOfficeRedmine::Attachment.find(id)
    end
  end

  class UserParameters
    extend T::Sig

    sig { params(hash: T.untyped, strict: T.untyped).returns(UserParameters) }
    def self.from_hash(hash, strict = nil)
      super(hash, strict)
    end

    sig { returns(T.nilable(OnlyOfficeRedmine::User)) }
    def user
      id = Integer(@user_id, 10)
      OnlyOfficeRedmine::User.find(id)
    end
  end
end
