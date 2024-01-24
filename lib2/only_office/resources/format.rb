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

module OnlyOffice::Resources
  class Format
    sig { returns(String) }
    def file_name
      # The order makes sense, because while the `document`, `presentation`,
      # `spreadsheet` work on the format type, the `form` works on the name.
      if docxf?
        return I18n.t("onlyoffice_create_docxf")
      end
      if document?
        return I18n.t("onlyoffice_create_docx")
      end
      if presentation?
        return I18n.t("onlyoffice_create_pptx")
      end
      if spreadsheet?
        return I18n.t("onlyoffice_create_xlsx")
      end
      I18n.t("field_filename")
    end

    sig { returns(String) }
    def favicon
      if form?
        return "#{name}.ico"
      end
      "#{type}.ico"
    end

    sig { returns(T::Boolean) }
    def form?
      docxf? || oform?
    end

    sig { returns(T::Boolean) }
    def docxf?
      name == "docxf"
    end

    sig { returns(T::Boolean) }
    def oform?
      name == "oform"
    end

    sig { returns(T::Boolean) }
    def image?
      bmp? || gif? || jpg? || png?
    end

    sig { returns(T::Boolean) }
    def bmp?
      name == "bmp"
    end

    sig { returns(T::Boolean) }
    def gif?
      name == "gif"
    end

    sig { returns(T::Boolean) }
    def jpg?
      name == "jpg"
    end

    sig { returns(T::Boolean) }
    def png?
      name == "png"
    end

    sig { returns(String) }
    def content_type
      mime.join(";")
    end
  end
end
