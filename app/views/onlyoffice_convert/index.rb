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

class Views::OnlyOfficeConvert::Index < Views::Mustache
  extend T::Sig
  include Blocks::Assets

  self.template_file = "#{template_path}/onlyoffice_convert/index.mustache"

  sig { override.params(helpers: T.untyped).void }
  def initialize(helpers:)
    super(helpers:)
    @helpers = helpers
    @title = I18n.t("onlyoffice_convert_dropdown")
    @input_basename = ""
    @input_size = ""
    @input_author = nil
    @input_create_on = ""
    @type_name = ""
    @type_save_value = ""
    @type_download_value = ""
    @input_id_name = ""
    @input_id_value = ""
    @page_id_name = ""
    @page_id_value = ""
    @page_type_name = ""
    @page_type_value = ""
    @output_name_label = I18n.t("field_name")
    @output_name_name = ""
    @output_name_value = ""
    @input_type_label = I18n.t("onlyoffice_convert_current_type")
    @input_type_name = ""
    @input_type_value = ""
    @output_type_label = I18n.t("onlyoffice_convert_end_type")
    @output_type_name = ""
    @output_type_placeholder = I18n.t("actionview_instancetag_blank_option")
    @output_type_options = []
    @save_url = nil
    @save_label = I18n.t("button_save")
    @download_url = ""
    @download_label = I18n.t("button_download")
    @cancel_url = nil
    @cancel_label = I18n.t("button_cancel")
  end

  def inline
    erb = raw_assets
    html = render.html_safe
    "#{erb}#{html}"
  end

  # Title

  sig { returns(String) }
  attr_accessor :title

  # File

  sig { returns(String) }
  attr_accessor :input_basename

  sig { returns(String) }
  attr_accessor :input_size

  sig { returns(String) }
  attr_accessor :input_author

  sig { returns(String) }
  attr_accessor :input_create_on

  # Fields

  sig { returns(String) }
  attr_accessor :type_name

  sig { returns(String) }
  attr_accessor :type_save_value

  sig { returns(String) }
  attr_accessor :type_download_value

  sig { returns(String) }
  attr_accessor :input_id_name

  sig { returns(String) }
  attr_accessor :input_id_value

  sig { returns(String) }
  attr_accessor :page_id_name

  sig { returns(String) }
  attr_accessor :page_id_value

  sig { returns(String) }
  attr_accessor :page_type_name

  sig { returns(String) }
  attr_accessor :page_type_value

  sig { returns(String) }
  attr_accessor :output_name_label

  sig { returns(String) }
  attr_accessor :output_name_name

  sig { returns(String) }
  attr_accessor :output_name_value

  sig { returns(String) }
  attr_accessor :input_type_label

  sig { returns(String) }
  attr_accessor :input_type_name

  sig { returns(String) }
  attr_accessor :input_type_value

  sig { returns(String) }
  attr_accessor :output_type_label

  sig { returns(String) }
  attr_accessor :output_type_name

  sig { returns(String) }
  attr_accessor :output_type_placeholder

  sig { returns(T::Array[String]) }
  attr_accessor :output_type_options

  # Actions

  sig { returns(T.nilable(String)) }
  attr_accessor :save_url

  sig { returns(String) }
  attr_accessor :save_label

  sig { returns(String) }
  attr_accessor :download_url

  sig { returns(String) }
  attr_accessor :download_label

  sig { returns(T.nilable(String)) }
  attr_accessor :cancel_url

  sig { returns(String) }
  attr_accessor :cancel_label
end
