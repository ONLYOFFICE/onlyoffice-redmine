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

# [Redmine Reference: View](https://github.com/redmine/redmine/blob/5.0.0/app/views/attachments/_links.html.erb) \
# [Redmine Reference: Helper](https://github.com/redmine/redmine/blob/5.0.0/app/helpers/attachments_helper.rb#L38)
module Blocks::Attachments
  extend T::Sig
  extend T::Helpers
  include Blocks::Helpers
  include Blocks::View::Icon
  include Blocks::Edit::Icon
  include Blocks::Convert::Icon
  abstract!

  sig { returns(T::Array[Blocks::Attachments::Attachment]) }
  def attachments
    @attachments ||= []
  end

  sig { returns(T.untyped) }
  def raw_attachments
    attachments.to_json
  end

  sig { params(container: T.untyped).void }
  def setup_attachments(container)
    attachments = resolve_attachments(container)
    attachments.each_with_index do |attachment, index|
      attach = Blocks::Attachment.define(helpers, attachment)
      next unless attach.view_url || attach.edit_url || attach.convert_url

      reattach = Blocks::Attachments::Attachment.reattach(index, attach)
      self.attachments.append(reattach)
    end
  end

  sig { params(container: T.untyped).returns(T.untyped) }
  def resolve_attachments(container)
    return container.attachments if container.attachments.loaded?
    container.attachments.preload(:author).to_a
  end
end

class Blocks::Attachments::Attachment < T::Struct
  extend T::Sig
  const :index, Integer
  const :view_url, T.nilable(String), default: nil
  const :edit_url, T.nilable(String), default: nil
  const :convert_url, T.nilable(String), default: nil

  def to_json(*_args)
    serialize
  end

  sig do
    params(
      index: Integer,
      attachment: Blocks::Attachment
    )
      .returns(Blocks::Attachments::Attachment)
  end
  def self.reattach(index, attachment)
    new(
      index:,
      view_url: attachment.view_url,
      edit_url: attachment.edit_url,
      convert_url: attachment.convert_url
    )
  end
end
