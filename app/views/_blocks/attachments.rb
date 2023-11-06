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

# [Redmine Reference](https://github.com/redmine/redmine/blob/5.0.0/app/views/attachments/_links.html.erb)
module Blocks::Attachments
  extend T::Sig
  extend T::Helpers
  include Blocks::View::Icon
  include Blocks::Edit::Icon
  include Blocks::Convert::Icon
  abstract!

  sig { returns(T::Array[Attachment]) }
  def attachments
    @attachments ||= []
  end

  sig { returns(T.untyped) }
  def raw_attachments
    attachments.to_json
  end

  sig { params(attachments: T::Array[Attachment]).void }
  def attachments=(attachments)
    @attachments = attachments
  end
end

class Blocks::Attachments::Attachment < T::Struct
  extend T::Sig
  prop :index,       T.nilable(Integer)
  prop :view_url,    T.nilable(String)
  prop :edit_url,    T.nilable(String)
  prop :convert_url, T.nilable(String)

  def to_json(*_args)
    serialize
  end

  sig { returns(T::Boolean) }
  def sense?
    unless view_url || edit_url || convert_url
      return false
    end
    true
  end
end
