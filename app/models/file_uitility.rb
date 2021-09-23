# Copyright (c) Ascensio System SIA 2021. All rights reserved.
# http://www.onlyoffice.com

class FileUtility
  @@exts_document = %w(.doc .docx .docm .dot .dotx .dotm .odt .fodt .ott .rtf .txt .html .htm .mht .xml .pdf .djvu .fb2 .epub .xps)
  @@exts_spreadsheet = %w(.xls .xlsx .xlsm .xlt .xltx .xltm .ods .fods .ots .csv)
  @@exts_presentation = %w(.pps .ppsx .ppsm .ppt .pptx .pptm .pot .potx .potm .odp .fodp .otp)

  class << self

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
      'word'
    end

    def is_openable(attachment)
      ext = File.extname(attachment.disk_filename).downcase
      if (@@exts_document.include? ext) || (@@exts_spreadsheet.include? ext) || (@@exts_presentation.include? ext)
        return true
      end
      return false
    end

  end
end
