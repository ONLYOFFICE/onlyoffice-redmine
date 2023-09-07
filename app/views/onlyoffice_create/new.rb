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

class Views::OnlyOfficeCreate::New < Views::Mustache
  extend T::Sig
  include Blocks::Assets

  self.template_file = "#{template_path}/onlyoffice_create/new.mustache"

  sig { override.params(helpers: T.untyped).void }
  def initialize(helpers:)
    super(helpers:)
    @helpers = helpers
    @title = I18n.t("onlyoffice_create_dropdown")
    @error_messages = ""
    @type_label = I18n.t("field_type")
    @type_name = ""
    @type_placeholder = I18n.t("actionview_instancetag_blank_option")
    @type_options = []
    @name_label = I18n.t("field_name")
    @name_name = ""
    @name_value = ""
    @description_label = I18n.t("field_description")
    @description_name = ""
    @create_label = I18n.t("button_create")
    @cancel_url = ""
    @cancel_label = I18n.t("button_cancel")
  end

  sig { returns(String) }
  def inline
    erb = raw_assets
    html = render.html_safe
    "#{erb}#{html}"
  end

  # Title

  sig { returns(String) }
  attr_accessor :title

  # Error

  sig { returns(String) }
  attr_accessor :error_messages

  # Fields

  sig { returns(String) }
  attr_accessor :type_label

  sig { returns(String) }
  attr_accessor :type_name

  sig { returns(String) }
  attr_accessor :type_placeholder

  sig { returns(T::Array[Views::OnlyOfficeCreate::TypeOption]) }
  attr_accessor :type_options

  sig { returns(String) }
  attr_accessor :name_label

  sig { returns(String) }
  attr_accessor :name_name

  sig { returns(String) }
  attr_accessor :name_value

  sig { returns(String) }
  attr_accessor :description_label

  sig { returns(String) }
  attr_accessor :description_name

  # Actions

  sig { returns(String) }
  attr_accessor :create_label

  sig { returns(String) }
  attr_accessor :cancel_url

  sig { returns(String) }
  attr_accessor :cancel_label
end

class Views::OnlyOfficeCreate::TypeOption < T::Struct
  const :label, String
  const :value, String
  const :selected, T::Boolean, default: false
  const :action, String
end
