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

class Blocks::Attachment < T::Struct
  extend T::Sig
  const :view_url, T.nilable(String), default: nil
  const :edit_url, T.nilable(String), default: nil
  const :convert_url, T.nilable(String), default: nil

  sig { params(helpers: T.untyped, attachment: T.untyped).returns(Blocks::Attachment) }
  def self.define(helpers, attachment)
    view_url = nil
    edit_url = nil
    convert_url = nil

    if viewable(attachment)
      view_url = helpers.onlyoffice_editor_path(attachment.id)
    end

    if editable(attachment)
      edit_url = view_url
    end

    if convertible(attachment)
      convert_url = helpers.onlyoffice_convert_convert_page_path(
        attachment.container_id,
        attachment.container_type,
        attachment.id
      )
    end

    new(view_url:, edit_url:, convert_url:)
  end

  sig { params(attachment: T.untyped).returns(T::Boolean) }
  def self.viewable(attachment)
    attachment.project &&
      (attachment.project.active? || attachment.project.closed?) &&
      attachment.visible? &&
      FileUtility.is_openable(attachment)
  end

  sig { params(attachment: T.untyped).returns(T::Boolean) }
  def self.editable(attachment)
    if attachment.container_type == "Project"
      return false
    end

    if attachment.container_type == "Issue"
      issue = Issue.find(attachment.container_id)
      return \
        !issue.closed? &&
        attachment.editable? &&
        DocumentHelper.is_editable(attachment)
    end

    attachment.project &&
      attachment.project.active? &&
      attachment.editable? &&
      DocumentHelper.is_editable(attachment)
  end

  sig { params(attachment: T.untyped).returns(T::Boolean) }
  def self.convertible(attachment)
    extenssion = DocumentHelper.file_ext(attachment.disk_filename, true)
    attachment.project &&
      (attachment.project.active? || attachment.project.closed?) &&
      attachment.visible? &&
      !FormatUtility.format_supported(extenssion).empty?
  end
end
