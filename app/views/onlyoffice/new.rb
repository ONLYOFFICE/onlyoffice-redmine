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

class Views::OnlyOffice::New < Views::Mustache
  extend T::Sig
  include Blocks::Assets

  self.template_file = "#{template_path}/onlyoffice/new.mustache"

  sig { returns(String) }
  attr_accessor :title

  sig { returns(String) }
  attr_accessor :error_messages

  sig { returns(Views::Input) }
  attr_accessor :name

  sig { returns(Views::Input) }
  attr_accessor :description

  sig { returns(Views::Select) }
  attr_accessor :format

  sig { returns(Views::Action) }
  attr_accessor :create

  sig { returns(Views::Action) }
  attr_accessor :cancel

  sig { override.params(helpers: T.untyped).void }
  def initialize(helpers:)
    super(helpers: helpers)
    @helpers = helpers

    title = I18n.t("onlyoffice_create_dropdown")
    @title = T.let(title, String)

    error_messages = ""
    @error_messages = T.let(error_messages, String)

    name = Views::Input.new
    name.label = I18n.t("field_name")
    @name = T.let(name, Views::Input)

    description = Views::Input.new
    description.label = I18n.t("field_description")
    @description = T.let(description, Views::Input)

    format = Views::Select.new
    format.label = I18n.t("field_type")
    format.options = [
      Views::Option.new(
        label: I18n.t("actionview_instancetag_blank_option"),
        selected: true
      )
    ]
    @format = T.let(format, Views::Select)

    create = Views::Action.new
    create.label = I18n.t("button_create")
    @create = T.let(create, Views::Action)

    cancel = Views::Action.new
    cancel.label = I18n.t("button_cancel")
    @cancel = T.let(cancel, Views::Action)
  end

  sig { override.returns(String) }
  def inline
    erb = raw_assets
    html = render.html_safe
    "#{erb}#{html}"
  end

  sig { returns(T.untyped) }
  def form_tag
    helpers_form_tag(create.url, multipart: false)
  end
end
