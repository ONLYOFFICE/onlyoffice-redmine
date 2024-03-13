#
# (c) Copyright Ascensio System SIA 2024
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

    view = Views::Attachments::Show.new(helpers: helpers)

    block = setup_link_to_attachment(helpers, user, attachment)
    unless block.sense?
      return ""
    end

    view.view_url = block.view_url
    view.edit_url = block.edit_url
    view.convert_url = block.convert_url

    # view.setup_assets
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
    container = OnlyOfficeRedmine::Document.new(document: document)

    view = Views::Documents::Show.new(helpers: helpers)
    view.attachments = setup_link_to_attachments(helpers, user, container)

    if container.addition_allowed?(user)
      view.new_url = helpers.onlyoffice_new_attachment_path(
        container.type,
        container.id
      )
    end

    if view.attachments.empty? && !view.new_url
      return ""
    end

    # view.setup_assets
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
  def self.show_files(helpers, containers)
    unless onlyoffice_plugin_available?
      return ""
    end

    user = OnlyOfficeRedmine::User.current

    view = Views::Files::Index.new(helpers: helpers)

    containers.each do |container|
      container.attachments.each do |attachment|
        block = setup_link_to_attachment(helpers, user, attachment)
        unless block.sense?
          next
        end
        view.attachments.append(block)
      end
    end

    if view.attachments.empty?
      return ""
    end

    # view.setup_assets
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
    container = OnlyOfficeRedmine::Issue.new(issue: issue)

    view = Views::Issues::Show.new(helpers: helpers)

    view.attachments = setup_link_to_attachments(helpers, user, container)
    if view.attachments.empty?
      return ""
    end

    # view.setup_assets
    view.inline
  end

  # ```http
  # GET /boards/{{board_id}}/topics/{{topic_id}}
  # Accept: text/html
  # Cookie: {{cookie}}
  # Host: {{plugin_url}}
  # ```
  #
  # [Redmine Reference](https://github.com/redmine/redmine/blob/5.0.0/app/controllers/messages_controller.rb#L36)
  sig do
    params(helpers: T.untyped, topic: ::Message, replies: T::Array[::Message])
      .returns(String)
  end
  def self.show_topic(helpers, topic, replies)
    unless onlyoffice_plugin_available?
      return ""
    end

    user = OnlyOfficeRedmine::User.current
    view = Views::Messages::Show.new(helpers: helpers)

    container = OnlyOfficeRedmine::Message.new(message: topic)
    view.attachments = setup_link_to_attachments(helpers, user, container)

    replies.each do |message|
      container = OnlyOfficeRedmine::Message.new(message: message)
      view.attachments += setup_link_to_attachments(helpers, user, container)
    end

    if view.attachments.empty?
      return ""
    end

    # view.setup_assets
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
  def self.show_news(helpers, news)
    unless onlyoffice_plugin_available?
      return ""
    end

    user = OnlyOfficeRedmine::User.current
    container = OnlyOfficeRedmine::News.new(news: news)

    view = Views::News::Show.new(helpers: helpers)

    view.attachments = setup_link_to_attachments(helpers, user, container)
    if view.attachments.empty?
      return ""
    end

    # view.setup_assets
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
    container = OnlyOfficeRedmine::WikiPage.new(page: page)

    view = Views::News::Show.new(helpers: helpers)

    view.attachments = setup_link_to_attachments(helpers, user, container)
    if view.attachments.empty?
      return ""
    end

    # view.setup_assets
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
  include OnlyOfficeRouterHelper
  include OnlyOfficeSettingsHelper
  include OnlyOfficeUserHelper
  include OnlyOfficeViewHelper::Regular

  before_action      :require_onlyoffice_plugin
  before_action      :check_trial
  skip_before_action :verify_authenticity_token, only: [:download, :retrieve, :callback]
  before_action      :verify_jwt_token,          only: [:download, :callback]
  before_action      :verify_fallback_jwt_token, only: [:retrieve]

  rescue_from OnlyOfficeRedmine::Error,         with: :handle_error
  rescue_from OnlyOfficeRedmine::SettingsError, with: :handle_settings_error

  def user_setup
    super
    case action_name
    when "download", "retrieve", "callback"
      resetup_user
    else
      # nothing
    end
  end

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

    return render_new(container)
  end

  # TODO: add additional options to create a new attachment.
  class CreatePayload < T::Struct
    prop :name,        String, default: ""
    prop :description, String, default: ""
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

    template = format.template
    unless template
      logger.error("The format (#{format.name}) doesn't have a template file")
      raise OnlyOfficeRedmine::Error.unsupported
    end

    scheme = OnlyOffice::Resources::TemplatesLanguageScheme.iso639_1
    blank = template.blank(I18n.locale.to_s, scheme)
    file = File.binread(blank)

    attachment = Attachment.create(
      file: file,
      author: user.internal,
      content_type: format.content_type,
      filename: payload.filename(format),
      description: payload.description
    )
    container.attachments.append(attachment)
    saved = container.save
    unless saved
      logger.error("Failed to save the #{container.type} (#{container.id}) with new attachment")
      return render_new(container)
    end

    flash[:notice] = I18n.t("notice_successful_create")
    home = container.home_path(helpers)
    redirect_to(home)
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

  sig { params(container: OnlyOfficeRedmine::Container).returns(T.untyped) }
  def render_new(container)
    view = Views::OnlyOffice::New.new(helpers: helpers)
    view.error_messages = helpers.error_messages_for(*container.attachments)
    view.name.name = "onlyoffice[name]"
    view.description.name = "onlyoffice[description]"

    formats = OnlyOfficeRedmine::Resources::Formats.read
    view.format.name = "onlyoffice[format]"
    view.format.options += formats.creatable.sort_by(&:order).map do |format|
      Views::Option.new(label: format.file_name, value: format.name)
    end

    view.create.url = helpers.onlyoffice_create_attachment_url(container.type, container.id)
    view.cancel.url = container.home_url(helpers)
    render_view(view)
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

    unless attachment.readable?
      logger.error("The attachment (#{attachment.id}) is unreadable")
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

    unless attachment.readable?
      logger.error("The attachment (#{attachment.id}) is unreadable")
      raise OnlyOfficeRedmine::Error.not_found
    end

    unless attachment.editable?(user) || attachment.fillable?(user)
      logger.error("User (#{user.id}) isn't allowed to edit or fill the attachment (#{attachment.id})")
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
    if settings.trial.enabled
      settings = settings.with_trial
    end

    attachment_payload = OnlyOfficeRouterHelper::AttachmentPayload.new(user_id: user.id)

    download_url = onlyoffice_download_attachment_url(attachment.id, attachment_payload)
    download_url = settings.plugin.resolve_internal_url(download_url)
    if settings.fallback_jwt.enabled
      download_url = settings.fallback_jwt.encode_url(download_url)
    end

    callback_url = onlyoffice_callback_attachment_url(attachment.id, attachment_payload)
    callback_url = settings.plugin.resolve_internal_url(callback_url)
    if settings.fallback_jwt.enabled
      callback_url = settings.fallback_jwt.encode_url(callback_url)
    end

    retrieve_url = onlyoffice_retrieve_attachment_url(attachment.id, attachment_payload)
    if settings.fallback_jwt.enabled
      retrieve_url = settings.fallback_jwt.encode_url(retrieve_url)
    end

    a = OnlyOffice::APP::Config.new(
      document: OnlyOffice::APP::Config::Document.new(
        url: download_url
      ),
      editor_config: OnlyOffice::APP::Config::EditorConfig.new(
        callback_url: callback_url,
        mode: mode
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

    view = Views::OnlyOffice::Editor.new(helpers: helpers)
    view.document_server_api_base_url = settings.document_server.url
    view.document_server_config = settings.jwt.encode_payload(f)
    view.retrieve_url = retrieve_url
    view.save_as_allowed = container.addition_allowed?(user)
    view.form = format.form?
    view.trial_enabled = settings.trial.enabled
    view.favicon = format.favicon
    view.basename = attachment.filename

    flash[:"onlyoffice-error_not-found error hidden"] \
      = I18n.t("onlyoffice_editor_cannot_be_reached")
    if format.form?
      flash[:"onlyoffice-error_forms-unsupported error hidden"] \
        = I18n.t("onlyoffice_editor_forms_error_version")
    end
    if settings.trial.enabled
      flash[:"onlyoffice-warning_trial-enabled warning hidden"] \
        = I18n.t("onlyoffice_editor_demo_enabled")
    end

    render_view(view)
  end

  # ```http
  # GET /onlyoffice/attachments/:attachment_id/download?user_id={{user_id}}&token={{fallback_jwt_token}} HTTP/1.1
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

    unless attachment.readable?
      logger.error("The attachment (#{attachment.id}) is unreadable")
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

    unless attachment.readable?
      logger.error("The attachment (#{attachment.id}) is unreadable")
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

    view = Views::OnlyOffice::Convert.new(helpers: helpers)

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

    unless attachment.readable?
      logger.error("The attachment (#{attachment.id}) is unreadable")
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
    if settings.trial.enabled
      settings = settings.with_trial
    end

    attachment_payload = OnlyOfficeRouterHelper::AttachmentPayload.new(user_id: user.id)

    download_url = onlyoffice_download_attachment_url(attachment.id, attachment_payload)
    download_url = settings.plugin.resolve_internal_url(download_url)
    if settings.fallback_jwt.enabled
      download_url = settings.fallback_jwt.encode_url(download_url)
    end

    client = settings.client
    http = client.http
    http.open_timeout = 5
    http.read_timeout = settings.conversion.timeout / 1000
    client = OnlyOffice::API::Client.new(base_url: client.base_url, http: http)

    conversion = OnlyOffice::API::Conversion.new(
      async: true,
      filetype: from.name,
      key: attachment.token,
      outputtype: to.name,
      region: I18n.locale.to_s,
      title: "#{payload.name}#{to.extension}",
      url: download_url
    )
    if to.image?
      conversion.thumbnail = OnlyOffice::API::Conversion::Thumbnail.new(
        first: false
      )
    end

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
        if result.file_type != to.name
          to = result.file_format
          unless to
            logger.error("The format (#{result.file_format}) doesn't supported")
            raise OnlyOfficeRedmine::Error.unsupported
          end
        end

        file_uri = URI(result.file_url)
        file = T.unsafe(file_uri).open(ssl_verify_mode: settings.ssl.verify_mode)

        attachment = Attachment.create(
          file: file,
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

    unless attachment.readable?
      logger.error("The attachment (#{attachment.id}) is unreadable")
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
    if settings.trial.enabled
      settings = settings.with_trial
    end

    attachment_payload = OnlyOfficeRouterHelper::AttachmentPayload.new(user_id: user.id)

    download_url = onlyoffice_download_attachment_url(attachment.id, attachment_payload)
    download_url = settings.plugin.resolve_internal_url(download_url)
    if settings.fallback_jwt.enabled
      download_url = settings.fallback_jwt.encode_url(download_url)
    end

    client = settings.client
    http = client.http
    http.open_timeout = 5
    http.read_timeout = settings.conversion.timeout / 1000
    client = OnlyOffice::API::Client.new(base_url: client.base_url, http: http)

    conversion = OnlyOffice::API::Conversion.new(
      async: true,
      filetype: from.name,
      key: attachment.token,
      outputtype: to.name,
      region: I18n.locale.to_s,
      title: "#{payload.name}#{to.extension}",
      url: download_url
    )
    if to.image?
      conversion.thumbnail = OnlyOffice::API::Conversion::Thumbnail.new(
        first: false
      )
    end

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

  class RetrievePayload < T::Struct
    prop :format_name, String, name: "format"
    prop :url,         String
  end

  # ```http
  # POST /onlyoffice/attachments/:attachment_id/retrieve?user_id={{user_id}}&token={{fallback_jwt_token}} HTTP/1.1
  # Accept: text/html
  # Content-Type: application/x-www-form-urlencoded; charset=utf-8
  # Host: {{plugin_url}}
  # ```
  def retrieve
    user_params = UserParameters.from_hash(request.parameters)
    user = user_params.user
    unless user
      logger.error("The user (#{user_params.user_id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    attachment_params = AttachmentParameters.from_hash(request.parameters)
    attachment = attachment_params.attachment
    unless attachment
      logger.error("The attachment (#{attachment_params.attachment_id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
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

    raw_payload = params["onlyoffice"].permit!.to_h
    retrieve_params = RetrievePayload.from_hash(raw_payload)

    format = retrieve_params.format
    unless format
      logger.error("The format (#{retrieve_params.format_name}) doesn't supported")
      raise OnlyOfficeRedmine::Error.unsupported
    end

    settings = OnlyOfficeRedmine::Settings.current
    settings.plugin.url = helpers.home_url
    if settings.trial.enabled
      settings = settings.with_trial
    end

    response = OnlyOffice::APP::CallbackError.new

    begin
      file_url = settings.document_server.resolve_internal_url(retrieve_params.url)
      file_uri = URI(file_url)
      file = T.unsafe(file_uri).open(ssl_verify_mode: settings.ssl.verify_mode)

      retrieved = Attachment.create(
        file: file,
        author: user.internal,
        content_type: format.content_type,
        filename: "#{attachment.name}#{format.extension}",
        description: attachment.description
      )

      container.attachments.append(retrieved)
      saved = container.save
      unless saved
        logger.error("Failed to save the #{container.type} (#{container.id}) with new attachment")
        raise OnlyOfficeRedmine::Error.internal
      end

      response.message = I18n.t("notice_successful_create")
    rescue OnlyOfficeRedmine::Error
      response.message = I18n.t("onlyoffice_attachment_create_error")
    end

    render(json: response.serialize)
  end

  class RetrievePayload
    extend T::Sig

    sig { params(hash: T.untyped, strict: T.untyped).returns(RetrievePayload) }
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
  end

  # ```http
  # POST /onlyoffice/attachments/{{attachment_id}}/callback?user_id={{user_id}}&token={{fallback_jwt_token}} HTTP/1.1
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

    unless attachment.readable?
      logger.error("The attachment (#{attachment.id}) is unreadable")
      raise OnlyOfficeRedmine::Error.not_found
    end

    user_params = UserParameters.from_hash(request.parameters)
    user = user_params.user
    unless user
      logger.error("The user (#{user_params.user_id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    unless attachment.editable?(user) || attachment.fillable?(user)
      logger.error("User (#{user.id}) isn't allowed to edit or fill the attachment (#{attachment.id})")
      raise OnlyOfficeRedmine::Error.forbidden
    end

    callback_json = request.body.read
    callback_hash = JSON.parse(callback_json)
    callback = OnlyOffice::APP::CallbackGeneric.from_hash(callback_hash)

    begin
      # rubocop:disable Lint/DuplicateBranch
      case callback
      when OnlyOffice::APP::CallbackBusy
        logger.info(callback.description)
      when OnlyOffice::APP::CallbackReady
        logger.info(callback.description)

        settings = OnlyOfficeRedmine::Settings.current
        settings.plugin.url = helpers.home_url
        if settings.trial.enabled
          settings = settings.with_trial
        end

        url = settings.document_server.resolve_internal_url(callback.url)
        uri = URI(url)

        tempfile = T.unsafe(uri).open(ssl_verify_mode: settings.ssl.verify_mode)
        unless tempfile
          logger.error("Failed to download file (#{url}) to save")
          raise OnlyOfficeRedmine::Error.internal
        end

        # rubocop:disable Style/StringHashKeys
        # We need a copy with an ID so that we can delete files from the disk.
        current = attachment.copy({ "id" => attachment.id })
        # rubocop:enable Style/StringHashKeys

        attachment.file = ActionDispatch::Http::UploadedFile.new(
          tempfile: tempfile,
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
    rescue OnlyOfficeRedmine::Error => e
      callback_error = OnlyOffice::APP::CallbackError.new(
        error: 1,
        message: "#{e.message}: #{callback.description}"
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
