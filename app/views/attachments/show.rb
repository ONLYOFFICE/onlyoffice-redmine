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

# [Redmine Reference: Controller](https://github.com/redmine/redmine/blob/5.0.0/app/controllers/attachments_controller.rb#L20) \
# [Redmine Reference: File View](https://github.com/redmine/redmine/blob/5.0.0/app/views/attachments/file.html.erb) \
# [Redmine Reference: Other View](https://github.com/redmine/redmine/blob/5.0.0/app/views/attachments/other.html.erb)
class Views::Attachments::Show < Views::Mustache
  extend T::Sig
  include Blocks::Assets
  include Blocks::View::Contextual
  include Blocks::Edit::Contextual
  include Blocks::Convert::Contextual

  self.template_file = "#{template_path}/attachments/show.mustache"

  sig { params(helpers: T.untyped, attachment: T.untyped).returns(String) }
  def self.inline(helpers:, attachment:)
    default = ""

    return default unless OnlyofficeController.checking_activity_onlyoffice

    attach = Blocks::Attachment.define(helpers, attachment)
    return default unless attach.view_url || attach.edit_url || attach.convert_url

    view = new(helpers:)
    view.setup_assets

    view.view_url = attach.view_url
    view.edit_url = attach.edit_url
    view.convert_url = attach.convert_url

    view.render.html_safe
  end
end
