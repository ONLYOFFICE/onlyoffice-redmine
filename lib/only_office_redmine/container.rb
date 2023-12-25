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

module OnlyOfficeRedmine
  module Container
    extend T::Sig
    extend T::Helpers
    abstract!

    Internal = T.type_alias do
      T.any(::Document, ::Issue, ::News, ::Project, ::WikiPage)
    end

    sig { abstract.returns(T.any(Integer, String)) }
    def id; end

    sig { abstract.returns(String) }
    def type; end

    sig { abstract.returns(Internal) }
    def internal; end

    sig { abstract.returns(::Project) }
    def project; end

    sig { abstract.returns(ActiveRecord::Associations::CollectionProxy) }
    def attachments; end

    sig { abstract.returns(ActiveModel::Errors) }
    def errors; end

    sig { abstract.returns(T::Boolean) }
    def save; end

    sig { abstract.params(user: User).returns(T::Boolean) }
    def addition_allowed?(user); end

    sig { abstract.params(helpers: T.untyped).returns(String) }
    def home_path(helpers); end

    sig { abstract.params(helpers: T.untyped).returns(String) }
    def home_url(helpers); end

    sig do
      overridable
        .params(helpers: T.untyped)
        .returns(OnlyOffice::APP::Config)
    end
    def app_config(helpers)
      OnlyOffice::APP::Config.new(
        editor_config: OnlyOffice::APP::Config::EditorConfig.new(
          customization: OnlyOffice::APP::Config::Customization.new(
            go_back: OnlyOffice::APP::Config::GenericGoBack.new(
              value: OnlyOffice::APP::Config::StructGoBack.new(
                url: home_url(helpers)
              )
            )
          )
        )
      )
    end
  end

  class GenericContainer
    extend T::Sig

    sig { params(id: String, type: String).returns(T.nilable(Container)) }
    def self.find(id, type)
      case type
      when Document.type
        id = Integer(id, 10)
        document = ::Document.find(id)
        unless document
          return nil
        end
        Document.new(document: document)
      when Issue.type
        id = Integer(id, 10)
        issue = ::Issue.find(id)
        unless issue
          return nil
        end
        Issue.new(issue: issue)
      when Message.type
        id = Integer(id, 10)
        message = ::Message.find(id)
        unless message
          return nil
        end
        Message.new(message: message)
      when News.type
        id = Integer(id, 10)
        news = ::News.find(id)
        unless news
          return nil
        end
        News.new(news: news)
      when Project.type
        project = ::Project.find(id)
        unless project
          return nil
        end
        Project.new(project: project)
      when WikiPage.type
        id = Integer(id, 10)
        page = ::WikiPage.find(id)
        unless page
          return nil
        end
        WikiPage.new(page: page)
      else
        nil
      end
    end

    sig { params(internal: T.untyped).returns(T.nilable(Container)) }
    def self.from_internal(internal)
      case internal
      when ::Document
        Document.new(document: internal)
      when ::Issue
        Issue.new(issue: internal)
      when ::Message
        Message.new(message: internal)
      when ::News
        News.new(news: internal)
      when ::Project
        Project.new(project: internal)
      when ::WikiPage
        WikiPage.new(page: internal)
      else
        nil
      end
    end
  end

  class Document
    extend T::Sig
    include Container

    sig { params(document: ::Document).void }
    def initialize(document:)
      @document = document
    end

    sig { override.returns(T.any(Integer, String)) }
    def id
      @document.id
    end

    sig { override.returns(String) }
    def type
      self.class.type
    end

    sig { returns(String) }
    def self.type
      "Document"
    end

    sig { override.returns(::Document) }
    def internal
      @document
    end

    sig { override.returns(::Project) }
    def project
      @document.project
    end

    sig { override.returns(ActiveRecord::Associations::CollectionProxy) }
    def attachments
      @document.attachments
    end

    sig { override.returns(ActiveModel::Errors) }
    def errors
      @document.errors
    end

    sig { override.returns(T::Boolean) }
    def save
      @document.save
    end

    sig { override.params(user: User).returns(T::Boolean) }
    def addition_allowed?(user)
      # https://github.com/redmine/redmine/blob/5.0.0/app/views/documents/show.html.erb#L30
      user.allowed_to?(
        {
          controller: "documents",
          action: "add_attachment"
        },
        @document.project
      )
    end

    sig { override.params(helpers: T.untyped).returns(String) }
    def home_path(helpers)
      helpers.document_path(@document)
    end

    sig { override.params(helpers: T.untyped).returns(String) }
    def home_url(helpers)
      helpers.document_url(@document)
    end
  end

  class Issue
    extend T::Sig
    include Container

    sig { params(issue: ::Issue).void }
    def initialize(issue:)
      @issue = issue
    end

    sig { override.returns(T.any(Integer, String)) }
    def id
      @issue.id
    end

    sig { override.returns(String) }
    def type
      self.class.type
    end

    sig { returns(String) }
    def self.type
      "Issue"
    end

    sig { override.returns(::Issue) }
    def internal
      @issue
    end

    sig { override.returns(::Project) }
    def project
      @issue.project
    end

    sig { override.returns(ActiveRecord::Associations::CollectionProxy) }
    def attachments
      @issue.attachments
    end

    sig { override.returns(ActiveModel::Errors) }
    def errors
      @issue.errors
    end

    sig { override.returns(T::Boolean) }
    def save
      @issue.save
    end

    sig { override.params(user: User).returns(T::Boolean) }
    def addition_allowed?(user)
      # https://github.com/redmine/redmine/blob/5.0.0/app/views/issues/_action_menu.html.erb#L4
      @issue.editable?(user.internal)
    end

    sig { override.params(helpers: T.untyped).returns(String) }
    def home_path(helpers)
      helpers.issue_path(@issue)
    end

    sig { override.params(helpers: T.untyped).returns(String) }
    def home_url(helpers)
      helpers.issue_url(@issue)
    end
  end

  class Message
    extend T::Sig
    include Container

    sig { params(message: ::Message).void }
    def initialize(message:)
      @message = message
    end

    sig { override.returns(T.any(Integer, String)) }
    def id
      @message.id
    end

    sig { override.returns(String) }
    def type
      self.class.type
    end

    sig { returns(String) }
    def self.type
      "Message"
    end

    sig { override.returns(::Message) }
    def internal
      @message
    end

    sig { override.returns(::Project) }
    def project
      @message.project
    end

    sig { override.returns(ActiveRecord::Associations::CollectionProxy) }
    def attachments
      @message.attachments
    end

    sig { override.returns(ActiveModel::Errors) }
    def errors
      @message.errors
    end

    sig { override.returns(T::Boolean) }
    def save
      @message.save
    end

    sig { override.params(user: User).returns(T::Boolean) }
    def addition_allowed?(user)
      # https://github.com/redmine/redmine/blob/5.0.0/app/views/messages/show.html.erb#L11
      @message.editable_by?(user.internal)
    end

    sig { override.params(helpers: T.untyped).returns(String) }
    def home_path(helpers)
      helpers.board_message_path(@message.board, @message)
    end

    sig { override.params(helpers: T.untyped).returns(String) }
    def home_url(helpers)
      helpers.board_message_url(@message.board, @message)
    end
  end

  class News
    extend T::Sig
    include Container

    sig { params(news: ::News).void }
    def initialize(news:)
      @news = news
    end

    sig { override.returns(T.any(Integer, String)) }
    def id
      @news.id
    end

    sig { override.returns(String) }
    def type
      self.class.type
    end

    sig { returns(String) }
    def self.type
      "News"
    end

    sig { override.returns(::News) }
    def internal
      @news
    end

    sig { override.returns(::Project) }
    def project
      @news.project
    end

    sig { override.returns(ActiveRecord::Associations::CollectionProxy) }
    def attachments
      @news.attachments
    end

    sig { override.returns(ActiveModel::Errors) }
    def errors
      @news.errors
    end

    sig { override.returns(T::Boolean) }
    def save
      @news.save
    end

    sig { override.params(user: User).returns(T::Boolean) }
    def addition_allowed?(user)
      # https://github.com/redmine/redmine/blob/5.0.0/app/views/news/show.html.erb#L8
      user.allowed_to?(:manage_news, @news.project)
    end

    sig { override.params(helpers: T.untyped).returns(String) }
    def home_path(helpers)
      helpers.news_path(@news)
    end

    sig { override.params(helpers: T.untyped).returns(String) }
    def home_url(helpers)
      helpers.news_url(@news)
    end
  end

  class Project
    extend T::Sig
    include Container

    sig { params(project: ::Project).void }
    def initialize(project:)
      @project = project
    end

    sig { override.returns(T.any(Integer, String)) }
    def id
      @project.id
    end

    sig { override.returns(String) }
    def type
      self.class.type
    end

    sig { returns(String) }
    def self.type
      "Project"
    end

    sig { override.returns(::Project) }
    def internal
      @project
    end

    sig { override.returns(::Project) }
    attr_reader :project

    sig { override.returns(ActiveRecord::Associations::CollectionProxy) }
    def attachments
      @project.attachments
    end

    sig { override.returns(ActiveModel::Errors) }
    def errors
      @project.errors
    end

    sig { override.returns(T::Boolean) }
    def save
      @project.save
    end

    sig { override.params(user: User).returns(T::Boolean) }
    def addition_allowed?(user)
      # https://github.com/redmine/redmine/blob/5.0.0/app/views/files/index.html.erb#L2
      user.allowed_to?(:manage_files, @project)
    end

    sig { override.params(helpers: T.untyped).returns(String) }
    def home_path(helpers)
      helpers.project_files_path(@project)
    end

    sig { override.params(helpers: T.untyped).returns(String) }
    def home_url(helpers)
      helpers.project_files_url(@project)
    end
  end

  class WikiPage
    extend T::Sig
    include Container

    sig { params(page: ::WikiPage).void }
    def initialize(page:)
      @page = page
    end

    sig { override.returns(T.any(Integer, String)) }
    def id
      @page.id
    end

    sig { override.returns(String) }
    def type
      self.class.type
    end

    sig { returns(String) }
    def self.type
      "WikiPage"
    end

    sig { override.returns(::WikiPage) }
    def internal
      @page
    end

    sig { override.returns(::Project) }
    def project
      @page.project
    end

    sig { override.returns(ActiveRecord::Associations::CollectionProxy) }
    def attachments
      @page.attachments
    end

    sig { override.returns(ActiveModel::Errors) }
    def errors
      @page.errors
    end

    sig { override.returns(T::Boolean) }
    def save
      @page.save
    end

    sig { override.params(user: User).returns(T::Boolean) }
    def addition_allowed?(user)
      # https://github.com/redmine/redmine/blob/5.0.0/app/views/files/index.html.erb#L2
      @page.editable_by?(user.internal) &&
        user.allowed_to?(
          {
            controller: "wiki",
            action: "add_attachment"
          },
          @page.project
        )
    end

    sig { override.params(helpers: T.untyped).returns(String) }
    def home_path(helpers)
      helpers.project_wiki_page_path(@page.project, @page.title)
    end

    sig { override.params(helpers: T.untyped).returns(String) }
    def home_url(helpers)
      helpers.project_wiki_page_url(@page.project, @page.title)
    end
  end
end
