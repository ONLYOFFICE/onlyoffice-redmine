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

class Views::OnlyOffice::Convert < Views::Mustache
  extend T::Sig
  include Blocks::Assets

  self.template_file = "#{template_path}/onlyoffice/convert.mustache"

  sig { returns(String) }
  attr_accessor :title

  sig { returns(Attachment) }
  attr_reader :attachment

  sig { returns(T.nilable(Views::Action)) }
  attr_accessor :save

  sig { returns(Views::Action) }
  attr_accessor :download

  sig { returns(Views::Action) }
  attr_accessor :cancel

  sig { override.params(helpers: T.untyped).void }
  def initialize(helpers:)
    super(helpers: helpers)
    @helpers = helpers

    title = I18n.t("onlyoffice_convert_dropdown")
    @title = T.let(title, String)

    attachment = Attachment.new
    attachment.name.label = I18n.t("field_name")
    attachment.description.label = I18n.t("field_description")
    attachment.from.label = I18n.t("label_date_from")
    attachment.to.label = I18n.t("label_date_to")
    attachment.to.options = [
      Views::Option.new(label: I18n.t("actionview_instancetag_blank_option"))
    ]
    @attachment = T.let(attachment, Attachment)

    save = Views::Action.new
    save.label = I18n.t("button_save")
    @save = T.let(save, T.nilable(Views::Action))

    download = Views::Action.new
    download.label = I18n.t("button_download")
    @download = T.let(download, Views::Action)

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
    helpers_form_tag(multipart: false)
  end
end

class Views::OnlyOffice::Convert::Attachment
  extend T::Sig

  sig { returns(String) }
  attr_accessor :basename

  sig { returns(String) }
  attr_accessor :size

  sig { returns(String) }
  attr_accessor :author

  sig { returns(String) }
  attr_accessor :create_on

  sig { returns(Views::Input) }
  attr_accessor :name

  sig { returns(Views::Input) }
  attr_accessor :description

  sig { returns(Views::Input) }
  attr_accessor :from

  sig { returns(Views::Select) }
  attr_accessor :to

  sig do
    params(
      basename: String,
      size: String,
      author: String,
      create_on: String,
      name: Views::Input,
      description: Views::Input,
      from: Views::Input,
      to: Views::Select
    )
      .void
  end
  def initialize(
    basename: "",
    size: "",
    author: "",
    create_on: "",
    name: Views::Input.new,
    description: Views::Input.new,
    from: Views::Input.new,
    to: Views::Select.new
  )
    @basename = basename
    @size = size
    @author = author
    @create_on = create_on
    @name = name
    @description = description
    @from = from
    @to = to
  end
end
