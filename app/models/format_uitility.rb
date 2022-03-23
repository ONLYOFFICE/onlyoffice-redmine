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

class FormatUtility
    @@supported_formats = nil
    @@download_as_exts = ["docx", "xlsx", "pptx"]

    class << self

        def format_supported(ext)

            case ext
                when "djvu"
                    @@supported_formats = ["bmp", "gif", "jpg","png"]
                when "doc"
                    @@supported_formats = ["bmp", "docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "gif", "html", "jpg", "odt", "ott", "pdf", "pdfa", "png", "rtf", "txt"]
                when "docm"
                    @@supported_formats = ["bmp", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "gif", "html", "jpg", "odt", "ott", "pdf", "pdfa", "png", "rtf", "txt"]
                when "docx"
                    @@supported_formats = ["bmp", "docm", "docxf", "dotm", "dotx", "epub", "fb2", "gif", "html", "jpg", "odt", "ott", "pdf", "pdfa", "png", "rtf", "txt"]
                when "docxf" 
                    @@supported_formats = ["bmp", "docm", "docx", "dotm", "dotx", "epub", "fb2", "gif", "html", "jpg", "odt", "ott", "pdf", "pdfa", "png", "rtf", "txt"]
                when "dot" 
                    @@supported_formats = ["bmp", "docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "gif", "html", "jpg", "odt", "ott", "pdf", "pdfa", "png", "rtf", "txt"]
                when "dotm" 
                    @@supported_formats = ["bmp", "docm", "docx", "docxf", "dotx", "epub", "fb2", "gif", "html", "jpg", "odt", "ott", "pdf", "pdfa", "png", "rtf", "txt"]
                when "dotx" 
                    @@supported_formats = ["bmp", "docm", "docx", "docxf", "dotm", "epub", "fb2", "gif", "html", "jpg", "odt", "ott", "pdf", "pdfa", "png", "rtf", "txt"]
                when "epub" 
                    @@supported_formats = ["bmp", "docm", "docx", "docxf", "dotm", "dotx", "fb2", "gif", "html", "jpg", "odt", "ott", "pdf", "pdfa", "png", "rtf", "txt"]
                when "fb2" 
                    @@supported_formats = ["bmp", "docm", "docx", "docxf", "dotm", "dotx", "epub", "gif", "html", "jpg", "odt", "ott", "pdf", "pdfa", "png", "rtf", "txt"]
                when "fodt" 
                    @@supported_formats = ["bmp", "docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "gif", "html", "jpg", "odt", "ott", "pdf", "pdfa", "png", "rtf", "txt"]
                when "html" 
                    @@supported_formats = ["bmp", "docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "gif", "jpg", "odt", "ott", "pdf", "pdfa", "png", "rtf", "txt"]
                when "mht" 
                    @@supported_formats = ["bmp", "docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "gif", "jpg", "odt", "ott", "pdf", "pdfa", "png", "rtf", "txt"]
                when "odt" 
                    @@supported_formats = ["bmp", "docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "gif", "html", "jpg", "ott", "pdf", "pdfa", "png", "rtf", "txt"]
                when "ott" 
                    @@supported_formats = ["bmp", "docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "gif", "html", "jpg", "odt", "pdf", "pdfa", "png", "rtf", "txt"]
                when "oxps" 
                    @@supported_formats = ["bmp", "gif", "jpg", "pdf", "pdfa", "png"]
                when "pdf" 
                    @@supported_formats = ["bmp", "gif", "jpg","png"]
                when "rtf" 
                    @@supported_formats = ["bmp", "docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "gif", "html", "jpg", "odt", "ott", "pdf", "pdfa", "png", "txt"]
                when "txt" 
                    @@supported_formats = ["bmp", "docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "gif", "html", "jpg", "odt", "ott", "pdf", "pdfa", "png", "rtf"]
                when "xps" 
                    @@supported_formats = ["bmp", "gif", "jpg", "pdf", "pdfa", "png"]
                when "xml" 
                    @@supported_formats = ["bmp", "docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "gif", "html", "jpg", "odt", "ott", "pdf", "pdfa", "png", "rtf", "txt"]
                when "oform" 
                    @@supported_formats = []


                when "csv" 
                    @@supported_formats = ["bmp", "gif", "jpg", "ods", "ots", "pdf", "pdfa", "png", "xlsm", "xlsx", "xltm", "xltx"]
                when "fods" 
                    @@supported_formats = ["bmp", "csv", "gif", "jpg", "ods", "ots", "pdf", "pdfa", "png", "xlsm", "xlsx", "xltm", "xltx"]
                when "ods" 
                    @@supported_formats = ["bmp", "csv", "gif", "jpg", "ots", "pdf", "pdfa", "png", "xlsm", "xlsx", "xltm", "xltx"]
                when "ots" 
                    @@supported_formats = ["bmp", "csv", "gif", "jpg", "ods", "pdf", "pdfa", "png", "xlsm", "xlsx", "xltm", "xltx"]
                when "xls" 
                    @@supported_formats = ["bmp", "csv", "gif", "jpg", "ods", "ots", "pdf", "pdfa", "png", "xlsm", "xlsx", "xltm", "xltx"]
                when "xlsm" 
                    @@supported_formats = ["bmp", "csv", "gif", "jpg", "ods", "ots", "pdf", "pdfa", "png", "xlsx", "xltm", "xltx"]
                when "xlsx" 
                    @@supported_formats = ["bmp", "csv", "gif", "jpg", "ods", "ots", "pdf", "pdfa", "png", "xlsm", "xltm", "xltx"]
                when "xlt" 
                    @@supported_formats = ["bmp", "csv", "gif", "jpg", "ods", "ots", "pdf", "pdfa", "png", "xlsm", "xlsx", "xltm", "xltx"]
                when "xltm" 
                    @@supported_formats = ["bmp", "csv", "gif", "jpg", "ods", "ots", "pdf", "pdfa", "png", "xlsm", "xlsx", "xltx"]
                when "xltx" 
                    @@supported_formats = ["bmp", "csv", "gif", "jpg", "ods", "ots", "pdf", "pdfa", "png", "xlsm", "xlsx", "xltm"]


                when "fodp" 
                    @@supported_formats = ["bmp", "gif", "jpg", "odp", "otp", "pdf", "pdfa", "png", "potm", "potx", "pptm", "pptx"]
                when "odp" 
                    @@supported_formats = ["bmp", "gif", "jpg", "otp", "pdf", "pdfa", "png", "potm", "potx", "pptm", "pptx"]
                when "otp" 
                    @@supported_formats = ["bmp", "gif", "jpg", "odp", "pdf", "pdfa", "png", "potm", "potx", "pptm", "pptx"]
                when "pot" 
                    @@supported_formats = ["bmp", "gif", "jpg", "odp", "otp", "pdf", "pdfa", "png", "potm", "potx", "pptm", "pptx"]
                when "potm" 
                    @@supported_formats = ["bmp", "gif", "jpg", "odp", "otp", "pdf", "pdfa", "png", "potx", "pptm", "pptx"]
                when "potx" 
                    @@supported_formats = ["bmp", "gif", "jpg", "odp", "otp", "pdf", "pdfa", "png", "potm", "pptm", "pptx"]
                when "pps" 
                    @@supported_formats = ["bmp", "gif", "jpg", "odp", "otp", "pdf", "pdfa", "png", "potm", "potx", "pptm", "pptx"]
                when "ppsm" 
                    @@supported_formats = ["bmp", "gif", "jpg", "odp", "otp", "pdf", "pdfa", "png", "potm", "potx", "pptm", "pptx"]
                when "ppsx" 
                    @@supported_formats = ["bmp", "gif", "jpg", "odp", "otp", "pdf", "pdfa", "png", "potm", "potx", "pptm", "pptx"]
                when "ppt" 
                    @@supported_formats = ["bmp", "gif", "jpg", "odp", "otp", "pdf", "pdfa", "png", "potm", "potx", "pptm", "pptx"]
                when "pptm" 
                    @@supported_formats = ["bmp", "gif", "jpg", "odp", "otp", "pdf", "pdfa", "png", "potm", "potx", "pptx"]
                when "pptx" 
                    @@supported_formats = ["bmp", "gif", "jpg", "odp", "otp", "pdf", "pdfa", "png", "potm", "potx", "pptm"]
            else
                @@supported_formats = []
            end
      
            return @@supported_formats
      
        end

        def is_download_as (ext)
            if @@download_as_exts.include? ext
                return true
            else
                return false
            end
        end
    end
end