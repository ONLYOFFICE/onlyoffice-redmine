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

# [Redmine Reference: Controller](https://github.com/redmine/redmine/blob/5.0.0/app/controllers/documents_controller.rb#L49) \
# [Redmine Reference: View](https://github.com/redmine/redmine/blob/5.0.0/app/views/documents/show.html.erb)
class Views::Documents::Show < Views::Mustache
  extend T::Sig
  include Blocks::Assets
  include Blocks::Attachments
  include Blocks::New::Anchor

  self.template_file = "#{template_path}/documents/show.mustache"

  sig { params(helpers: T.untyped, document: T.untyped).returns(String) }
  def self.inline(helpers:, document:)
    default = ""

    return default unless \
      OnlyofficeController.checking_activity_onlyoffice &&
      document.project.active?

    view = new(helpers:)
    view.setup_assets
    view.setup_attachments(document)

    allowed_to_add = User.current.allowed_to?(
      {
        controller: "documents",
        action: "add_attachment"
      },
      document.project
    )
    if allowed_to_add
      view.new_url = helpers.onlyoffice_create_new_2_path(
        document.project,
        document.id,
        "docx"
      )
    end

    view.render.html_safe
  end
end
