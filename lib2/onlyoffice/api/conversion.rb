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

require "sorbet-runtime"
require_relative "service"

module OnlyOffice; end

module OnlyOffice::API
  class ConversionService < Service; end

  class Conversion < T::Struct
    class DocumentLayout < T::Struct
      prop :draw_place_holders,  T.nilable(T::Boolean), name: "drawPlaceHolders"
      prop :draw_form_highlight, T.nilable(T::Boolean), name: "drawFormHighlight"
      prop :is_print,            T.nilable(T::Boolean), name: "isPrint"
    end

    class DocumentRenderer < T::Struct
      prop :text_association, T.nilable(String), name: "textAssociation"
    end

    class SpreadsheetLayout < T::Struct
      class Margins < T::Struct
        prop :bottom, T.nilable(String)
        prop :left,   T.nilable(String)
        prop :right,  T.nilable(String)
        prop :top,    T.nilable(String)
      end

      class PageSize < T::Struct
        prop :height, T.nilable(String)
        prop :width,  T.nilable(String)
      end

      prop :fit_to_height,     T.nilable(Integer),    name: "fitToHeight"
      prop :fit_to_width,      T.nilable(Integer),    name: "fitToWidth"
      prop :grid_lines,        T.nilable(T::Boolean), name: "gridLines"
      prop :headings,          T.nilable(T::Boolean), name: "headings"
      prop :ignore_print_area, T.nilable(T::Boolean), name: "ignorePrintArea"
      prop :margins,           T.nilable(Margins)
      prop :orientation,       T.nilable(String)
      prop :page_size,         T.nilable(PageSize),   name: "pageSize"
      prop :scale,             T.nilable(Integer)
    end

    class Thumbnail < T::Struct
      prop :aspect, T.nilable(Integer)
      prop :first,  T.nilable(T::Boolean)
      prop :height, T.nilable(Integer)
      prop :width,  T.nilable(Integer)
    end

    prop :async,              T.nilable(T::Boolean)
    prop :code_page,          T.nilable(Integer),           name: "codePage"
    prop :delimiter,          T.nilable(Integer)
    prop :document_layout,    T.nilable(DocumentLayout),    name: "documentLayout"
    prop :document_renderer,  T.nilable(DocumentRenderer),  name: "documentRenderer"
    prop :filetype,           T.nilable(String)
    prop :key,                T.nilable(String)
    prop :outputtype,         T.nilable(String)
    prop :password,           T.nilable(String)
    prop :region,             T.nilable(String)
    prop :spreadsheet_layout, T.nilable(SpreadsheetLayout), name: "spreadsheetLayout"
    prop :thumbnail,          T.nilable(Thumbnail)
    prop :title,              T.nilable(String)
    prop :url,                String,                       default: ""
  end

  ConversionResult = T.type_alias do
    T.any(ConversionComplete, ConversionProgress)
  end

  class ConversionComplete < T::Struct
    prop :end_convert, T::Boolean, name: "endConvert"
    prop :file_type,   String,     name: "fileType"
    prop :file_url,    String,     name: "fileUrl"
    prop :percent,     Integer
  end

  class ConversionProgress < T::Struct
    prop :end_convert, T::Boolean, name: "endConvert"
    prop :percent,     Integer
  end

  class ConversionError < T::Struct
    prop :error, Integer
  end

  class ConversionService
    sig do
      params(conversion: Conversion)
        .returns([T.any(ConversionResult, ConversionError), Net::HTTPResponse])
    end
    def convert(conversion)
      request = conversion.serialize
      http_request = @client.post("/ConvertService.ashx", request)
      response, http_response = @client.start(http_request)

      begin
        error = ConversionError.from_hash(response)
        return [error, http_response]
      rescue StandardError
        # continue
      end

      begin
        complete = ConversionComplete.from_hash(response)
        return [complete, http_response]
      rescue StandardError
        # continue
      end

      progress = ConversionProgress.from_hash(response)
      [progress, http_response]
    end
  end

  class ConversionError
    extend T::Sig

    sig { returns(String) }
    def description
      case error
      when -1
        "Unknown error"
      when -2
        "Conversion timeout error"
      when -3
        "Conversion error"
      when -4
        "Error while downloading the document file to be converted"
      when -5
        "Incorrect password"
      when -6
        "Error while accessing the conversion result database"
      when -7
        "Input error"
      when -8
        "Invalid token"
      else
        "Unknown error code"
      end
    end
  end
end
