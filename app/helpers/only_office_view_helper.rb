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

module OnlyOfficeViewHelper
  module Regular
    extend T::Sig
    extend T::Helpers
    include Kernel
    abstract!

    sig { params(view: Views::Mustache).returns(T.untyped) }
    private def render_view(view)
      ac = T.cast(self, ApplicationController)
      ac.render(inline: view.inline, layout: "base")
    end
  end

  module Injection
    extend T::Sig
    extend T::Helpers
    abstract!

    # [Redmine Reference](https://github.com/redmine/redmine/blob/5.0.0/app/helpers/attachments_helper.rb#L38)
    sig do
      params(
        helpers: T.untyped,
        user: OnlyOfficeRedmine::User,
        container: OnlyOfficeRedmine::Container
      )
        .returns(T::Array[Blocks::Attachments::Attachment])
    end
    private def setup_link_to_attachments(helpers, user, container)
      blocks = T.let([], T::Array[Blocks::Attachments::Attachment])

      attachments =
        if container.attachments.loaded?
          container.attachments
        else
          container.attachments.preload(:author).to_a
        end

      attachments.each_with_index do |attachment, index|
        block = setup_link_to_attachment(helpers, user, attachment)
        unless block.sense?
          next
        end

        block.index = index
        blocks.append(block)
      end

      blocks
    end

    sig do
      params(
        helpers: T.untyped,
        user: OnlyOfficeRedmine::User,
        attachment: ::Attachment
      )
        .returns(Blocks::Attachments::Attachment)
    end
    private def setup_link_to_attachment(helpers, user, attachment)
      attachment = OnlyOfficeRedmine::Attachment.new(attachment:)
      block = Blocks::Attachments::Attachment.new

      if attachment.editable?(user) || attachment.fillable?(user)
        block.edit_url = helpers.onlyoffice_edit_attachment_path(attachment.id)
      elsif attachment.viewable?(user)
        block.view_url = helpers.onlyoffice_view_attachment_path(attachment.id)
      end

      if attachment.convertible?(user)
        block.convert_url = helpers.onlyoffice_convert_attachment_path(attachment.id)
      end

      block
    end
  end
end
