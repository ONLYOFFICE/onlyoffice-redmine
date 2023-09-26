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

# [Redmine Reference: Controller](https://github.com/redmine/redmine/blob/5.0.0/app/controllers/issues_controller.rb#L95) \
# [Redmine Reference: View](https://github.com/redmine/redmine/blob/5.0.0/app/views/issues/show.html.erb)
class Views::Issues::Show < Views::Mustache
  extend T::Sig
  include Blocks::Assets
  include Blocks::Attachments

  self.template_file = "#{template_path}/issues/show.mustache"

  sig { params(helpers: T.untyped, issue: T.untyped).returns(String) }
  def self.inline(helpers:, issue:)
    view = new(helpers:)
    view.setup_assets
    view.setup_attachments(issue)
    view.render.html_safe
  end
end
