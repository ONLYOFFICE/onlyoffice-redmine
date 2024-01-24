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

module Blocks::Assets
  extend T::Sig
  extend T::Helpers
  include Blocks::Helpers
  abstract!

  sig { void }
  def setup_assets
    helpers.content_for(:header_tags, plugin_styles)
    helpers.content_for(:header_tags, plugin_scripts)
  end

  sig { returns(String) }
  def raw_assets
    "<% content_for(:header_tags) do %>" \
      "#{plugin_styles}" \
      "#{plugin_scripts}" \
      "<% end %>"
  end

  sig { returns(String) }
  def plugin_styles
    helpers_stylesheet_link_tag("main")
  end

  sig { returns(String) }
  def plugin_scripts
    javascript_include_tag("main")
  end
end
