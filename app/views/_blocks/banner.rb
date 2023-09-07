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

module Blocks::Banner
  def banner_heading
    I18n.t("onlyoffice_settings_banner_heading")
  end

  def banner_description
    I18n.t("onlyoffice_settings_banner_description")
  end

  def banner_go_label
    I18n.t("onlyoffice_settings_banner_go")
  end

  def banner_go_url
    "https://www.onlyoffice.com/docs-registration.aspx"
  end
end
