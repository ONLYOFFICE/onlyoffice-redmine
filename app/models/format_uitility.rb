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

    class << self

        def format_supported(ext)

            case ext
                when "djvu"
                    @@supported_formats = []
                when "doc"
                    @@supported_formats = ["docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "html", "odt", "ott", "pdf", "pdfa", "rtf", "txt"]
                when "docm"
                    @@supported_formats = ["docx", "docxf", "dotm", "dotx", "epub", "fb2", "html", "odt", "ott", "pdf", "pdfa", "rtf", "txt"]
                when "docx"
                    @@supported_formats = ["docm", "docxf", "dotm", "dotx", "epub", "fb2", "html", "odt", "ott", "pdf", "pdfa", "rtf", "txt"]
                when "docxf" 
                    @@supported_formats = ["docm", "docx", "dotm", "dotx", "epub", "fb2", "html", "odt", "ott", "pdf", "pdfa", "rtf", "txt"]
                when "dot" 
                    @@supported_formats = ["docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "html", "odt", "ott", "pdf", "pdfa", "rtf", "txt"]
                when "dotm" 
                    @@supported_formats = ["docm", "docx", "docxf", "dotx", "epub", "fb2", "html", "odt", "ott", "pdf", "pdfa", "rtf", "txt"]
                when "dotx" 
                    @@supported_formats = ["docm", "docx", "docxf", "dotm", "epub", "fb2", "html", "odt", "ott", "pdf", "pdfa", "rtf", "txt"]
                when "epub" 
                    @@supported_formats = ["docm", "docx", "docxf", "dotm", "dotx", "fb2", "html", "odt", "ott", "pdf", "pdfa", "rtf", "txt"]
                when "fb2" 
                    @@supported_formats = ["docm", "docx", "docxf", "dotm", "dotx", "epub", "html", "odt", "ott", "pdf", "pdfa", "rtf", "txt"]
                when "fodt" 
                    @@supported_formats = ["docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "html", "odt", "ott", "pdf", "pdfa", "rtf", "txt"]
                when "html" 
                    @@supported_formats = ["docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "odt", "ott", "pdf", "pdfa", "rtf", "txt"]
                when "mht" 
                    @@supported_formats = ["docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "odt", "ott", "pdf", "pdfa", "rtf", "txt"]
                when "odt" 
                    @@supported_formats = ["docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "html", "ott", "pdf", "pdfa", "rtf", "txt"]
                when "ott" 
                    @@supported_formats = ["docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "html", "odt", "pdf", "pdfa", "rtf", "txt"]
                when "oxps" 
                    @@supported_formats = ["pdf", "pdfa"]
                when "pdf" 
                    @@supported_formats = []
                when "rtf" 
                    @@supported_formats = ["docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "html", "odt", "ott", "pdf", "pdfa", "txt"]
                when "txt" 
                    @@supported_formats = []
                    #@@supported_formats = ["docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "html", "odt", "ott", "pdf", "pdfa", "rtf"]
                when "xps" 
                    @@supported_formats = ["pdf", "pdfa"]
                when "xml" 
                    @@supported_formats = ["docm", "docx", "docxf", "dotm", "dotx", "epub", "fb2", "html", "odt", "ott", "pdf", "pdfa", "rtf", "txt"]
                when "oform" 
                    @@supported_formats = []


                when "csv" 
                    @@supported_formats = []
                    #@@supported_formats = ["ods", "ots", "pdf", "pdfa", "xlsm", "xlsx", "xltm", "xltx"]
                when "fods" 
                    @@supported_formats = ["csv", "ods", "ots", "pdf", "pdfa", "xlsm", "xlsx", "xltm", "xltx"]
                when "ods" 
                    @@supported_formats = ["csv", "ots", "pdf", "pdfa", "xlsm", "xlsx", "xltm", "xltx"]
                when "ots" 
                    @@supported_formats = ["csv", "ods", "pdf", "pdfa", "xlsm", "xlsx", "xltm", "xltx"]
                when "xls" 
                    @@supported_formats = ["csv", "ods", "ots", "pdf", "pdfa", "xlsm", "xlsx", "xltm", "xltx"]
                when "xlsm" 
                    @@supported_formats = ["csv", "ods", "ots", "pdf", "pdfa", "xlsx", "xltm", "xltx"]
                when "xlsx" 
                    @@supported_formats = ["csv", "ods", "ots", "pdf", "pdfa", "xlsm", "xltm", "xltx"]
                when "xlt" 
                    @@supported_formats = ["csv", "ods", "ots", "pdf", "pdfa", "xlsm", "xlsx", "xltm", "xltx"]
                when "xltm" 
                    @@supported_formats = ["csv", "ods", "ots", "pdf", "pdfa", "xlsm", "xlsx", "xltx"]
                when "xltx" 
                    @@supported_formats = ["csv", "ods", "ots", "pdf", "pdfa", "xlsm", "xlsx", "xltm"]


                when "fodp" 
                    @@supported_formats = ["odp", "otp", "pdf", "pdfa", "potm", "potx", "pptm", "pptx"]
                when "odp" 
                    @@supported_formats = ["otp", "pdf", "pdfa", "potm", "potx", "pptm", "pptx"]
                when "otp" 
                    @@supported_formats = ["odp", "pdf", "pdfa", "potm", "potx", "pptm", "pptx"]
                when "pot" 
                    @@supported_formats = ["odp", "otp", "pdf", "pdfa", "potm", "potx", "pptm", "pptx"]
                when "potm" 
                    @@supported_formats = ["odp", "otp", "pdf", "pdfa", "potx", "pptm", "pptx"]
                when "potx" 
                    @@supported_formats = ["odp", "otp", "pdf", "pdfa", "potm", "pptm", "pptx"]
                when "pps" 
                    @@supported_formats = ["odp", "otp", "pdf", "pdfa", "potm", "potx", "pptm", "pptx"]
                when "ppsm" 
                    @@supported_formats = ["odp", "otp", "pdf", "pdfa", "potm", "potx", "pptm", "pptx"]
                when "ppsx" 
                    @@supported_formats = ["odp", "otp", "pdf", "pdfa", "potm", "potx", "pptm", "pptx"]
                when "ppt" 
                    @@supported_formats = ["odp", "otp", "pdf", "pdfa", "potm", "potx", "pptm", "pptx"]
                when "pptm" 
                    @@supported_formats = ["odp", "otp", "pdf", "pdfa", "potm", "potx", "pptx"]
                when "pptx" 
                    @@supported_formats = ["odp", "otp", "pdf", "pdfa", "potm", "potx", "pptm"]
            else
                @@supported_formats = []
            end
      
            return @@supported_formats
      
        end

        def not_supported_convert_formats
            return FileUtility.get_all_available_formats.find_all{ |elem| format_supported(elem[1..]).length == 0 }
        end
    end
end