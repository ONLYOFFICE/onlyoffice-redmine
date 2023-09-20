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

class Views::OnlyOffice::Editor < Views::Mustache
  extend T::Sig
  include Blocks::Assets

  self.template_file = "#{template_path}/onlyoffice/editor.mustache"

  sig { override.params(helpers: T.untyped).void }
  def initialize(helpers:)
    super(helpers:)
    @document_server_api_url = ""
    @document_server_config = {}.to_json
    @save_as_url = ""
    @format = ""
    @message = I18n.t("onlyoffice_editor_cannot_be_reached")
    @basename = ""
  end

  sig { returns(String) }
  def inline
    erb = "#{raw_assets}#{document_server_api_raw}"
    html = render.html_safe
    "#{erb}#{html}"
  end

  sig { returns(String) }
  attr_accessor :document_server_api_url

  sig { returns(String) }
  def document_server_api_script
    @helpers.javascript_include_tag(document_server_api_url)
  end

  sig { returns(String) }
  def document_server_api_raw
    "<% content_for(:header_tags) do %>" \
      "#{document_server_api_script}" \
      "<% end %>"
  end

  sig { returns(T.untyped) }
  attr_accessor :document_server_config

  sig { returns(String) }
  attr_accessor :save_as_url

  sig { returns(String) }
  attr_accessor :format

  sig { returns(T.nilable(String)) }
  def favicon_url
    pattern = Regexp.new("src=\"([\\S\\s].*?)\"")
    tag = helpers_image_tag("favicons/#{format}.ico")

    data = pattern.match(tag)
    return unless data

    source = data[1]
    return unless source

    source
  end

  sig { returns(String) }
  attr_accessor :message

  sig { returns(String) }
  attr_accessor :basename

  sig { returns(String) }
  def title
    "#{basename} — ONLYOFFICE"
  end
end