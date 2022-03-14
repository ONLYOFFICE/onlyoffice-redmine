#
# (c) Copyright Ascensio System SIA 2022
# http://www.onlyoffice.com
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

class FileUtility
  @@exts_document = %w(.doc .docx .docm .dot .dotx .dotm .docxf .oform .odt .fodt .ott .rtf .txt .html .htm .mht .xml .pdf .djvu .fb2 .epub .xps)
  @@exts_spreadsheet = %w(.xls .xlsx .xlsm .xlt .xltx .xltm .ods .fods .ots .csv)
  @@exts_presentation = %w(.pps .ppsx .ppsm .ppt .pptx .pptm .pot .potx .potm .odp .fodp .otp)

  @@exts_new_docs = %w(.docx .xlsx .pptx .docxf)

  @@exts_mimetypes = {
    :docx => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    :xlsx => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    :pptx => "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    :docxf => "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  }

  class << self

    def get_all_available_formats
      return @@exts_document.to_a + @@exts_spreadsheet.to_a + @@exts_presentation
    end

    def get_file_type(file_name)
      ext = File.extname(file_name).downcase
      if @@exts_document.include? ext
        return 'word'
      end
      if @@exts_spreadsheet.include? ext
        return 'cell'
      end
      if @@exts_presentation.include? ext
        return 'slide'
      end
    end

    def is_openable(attachment)
      ext = File.extname(attachment.disk_filename).downcase
      if (@@exts_document.include? ext) || (@@exts_spreadsheet.include? ext) || (@@exts_presentation.include? ext)
        return true
      end
      return false
    end

    def can_create(ext)
      if (@@exts_new_docs.include? '.' + ext.downcase)
        return true
      end
      return false
    end

    def get_mimetype(ext)
      if (@@exts_mimetypes.key?(ext))
        return @@exts_mimetypes[ext.to_sym]
      else
        return @@exts_mimetypes[:docx]
      end
    end

    def get_editor_internal_url
      url = Setting.plugin_onlyoffice_redmine["inner_editor"]
      if !url.present?
        url = Config.get_config("oo_address")
      end
      return Config.check_valid_url(url)
    end

    def get_redmine_internal_url
      url = Setting.plugin_onlyoffice_redmine["inner_server"]
      if !url.present?
        port = Setting.host_name[Setting.host_name.rindex(':'), Setting.host_name.length]
        host = Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address
        url = Setting.protocol + "://" + host + port
        return Config.check_valid_url(url)
      end
    end

    def replace_doc_edito_url_to_internal(url)
      innerUrl = get_editor_internal_url
      publicUrl = Config.get_config("oo_address")
      if !innerUrl.eql?(publicUrl) && !Setting.plugin_onlyoffice_redmine["editor_demo"].eql?("on")
        if innerUrl.present? && publicUrl.present?
          url = url.sub(publicUrl, innerUrl)
        end
      end
      return url
    end

  end
end
