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

# [Redmine Reference: Controller](https://github.com/redmine/redmine/blob/5.0.0/app/controllers/files_controller.rb#L31) \
# [Redmine Reference: View](https://github.com/redmine/redmine/blob/5.0.0/app/views/documents/show.html.erb)
class Views::Files::Index < Views::Mustache
  extend T::Sig
  include Blocks::Assets
  include Blocks::Attachments

  self.template_file = "#{template_path}/files/index.mustache"

  sig { params(helpers: T.untyped, containers: T.untyped).returns(String) }
  def self.inline(helpers:, containers:)
    default = ""

    return default unless OnlyofficeController.checking_activity_onlyoffice

    view = new(helpers:)
    view.setup_assets

    containers.each do |container|
      container.attachments.each_with_index do |attachment, index|
        attach = Blocks::Attachment.define(helpers, attachment)
        next unless attach.view_url || attach.edit_url || attach.convert_url

        reattach = Blocks::Attachments::Attachment.reattach(index, attach)
        view.attachments.append(reattach)
      end
    end

    view.render.html_safe
  end
end
