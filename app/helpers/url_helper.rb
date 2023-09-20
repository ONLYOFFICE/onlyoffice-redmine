#
# (c) Copyright Ascensio System SIA 2022
# http://www.onlyoffice.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class UrlHelper

    class << self
        
        def fix_url(url)
            if (url.nil?)
                return url
            end
            stripped = url.strip
            if (stripped.empty?)
                return stripped
            end
            return stripped.end_with?("/") ? stripped : stripped + "/"
        end

        def replace_doc_editor_url_to_internal(url)
            inner_url = Config.get_docserver_url()
            public_url = Config.get_docserver_url(false)

            if inner_url.nil? || inner_url.empty? || inner_url.eql?(public_url)
                return url
            end

            return url.sub(public_url, inner_url)
        end

    end

end