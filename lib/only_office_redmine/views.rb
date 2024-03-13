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

module OnlyOfficeRedmine
  class Views < Redmine::Hook::ViewListener
    extend T::Sig

    def view_layouts_base_html_head(ctx)
      html = ""

      if ctx == nil
        return html
      end

      c = ctx[:controller]
      if c == nil
        return html
      end

      r = ctx[:request]
      if r == nil
        return html
      end

      a = r[:action]
      if a == nil
        return html
      end

      html = view_layouts_base_body_bottom(ctx)
      if html != ""
        h = Head.new(helpers: c.helpers)
        html = h.plugin_styles
        html += h.plugin_scripts
      end

      html
    end

    def view_layouts_base_body_bottom(ctx)
      html = ""

      if ctx == nil
        return html
      end

      c = ctx[:controller]
      if c == nil
        return html
      end

      r = ctx[:request]
      if r == nil
        return html
      end

      a = r[:action]
      if a == nil
        return html
      end

      case c
      when ::AttachmentsController
        case a
        when "show"
          attachment = c.instance_variable_get(:@attachment)
          html = OnlyOfficeAttachmentsController.show_attachment(c.helpers, attachment)
        else
          # do nothing
        end

      when ::DocumentsController
        case a
        when "show"
          document = c.instance_variable_get(:@document)
          html = OnlyOfficeAttachmentsController.show_document(c.helpers, document)
        else
          # do nothing
        end

      when ::FilesController
        case a
        when "index"
          containers = c.instance_variable_get(:@containers)
          html = OnlyOfficeAttachmentsController.show_files(self, containers)
        else
          # do nothing
        end

      when ::IssuesController
        case a
        when "show"
          issue = c.instance_variable_get(:@issue)
          html = OnlyOfficeAttachmentsController.show_issue(self, issue)
        else
          # do nothing
        end

      when ::MessagesController
        case a
        when "show"
          topic = c.instance_variable_get(:@topic)
          replies = c.instance_variable_get(:@replies)
          html = OnlyOfficeAttachmentsController.show_topic(self, topic, replies)
        else
          # do nothing
        end

      when ::NewsController
        case a
        when "show"
          news = c.instance_variable_get(:@news)
          html = OnlyOfficeAttachmentsController.show_news(self, news)
        else
          # do nothing
        end

      when ::WikiController
        case a
        when "show"
          page = c.instance_variable_get(:@page)
          html = OnlyOfficeAttachmentsController.show_wiki_page(self, page)
        else
          # do nothing
        end

      else
        # do nothing
      end

      html
    end
  end

  class Head
    extend  T::Sig
    include Blocks::Assets

    sig { override.returns(T.untyped) }
    attr_reader :helpers

    sig { overridable.params(helpers: T.untyped).void }
    def initialize(helpers:)
      @helpers = helpers
    end
  end
end
