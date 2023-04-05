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

class ServiceConverter

    @@convert_timeout = 120  # get the convertion timeout from the config
    @@document_converter_url = "ConvertService.ashx"  # get the converter url from the config

    class << self
        # get the url of the converted file
  def get_converted_uri(doc_server_url, title, document_uri, from_ext, to_ext, document_revision_id)

        payload = {  # write all the conversion parameters to the payload
          :async => false,
          :url => document_uri,
          :outputtype => to_ext.delete('.'),
          :filetype => from_ext.delete('.'),
          :title => title,
          :key => document_revision_id,
          :region => I18n.locale
        }

        data = nil
        begin
          uri = URI.parse(doc_server_url + @@document_converter_url)  # create the request url
          http = Net::HTTP.new(uri.host, uri.port)  # create a connection to the http server

          CallbackHelper.check_cert(uri.to_s, http)

          http.read_timeout = @@convert_timeout
          req = Net::HTTP::Post.new(uri.request_uri)  # create the post request
          req.add_field("Accept", "application/json")  # set headers
          req.add_field("Content-Type", "application/json")
          JwtHelper.init
      if JwtHelper.is_enabled
        payload["token"] = JwtHelper.encode(payload)  # get token and save it to the payload
        jwt_header = JwtHelper.jwt_header # get signature authorization header
        req.add_field(jwt_header, "Bearer #{JwtHelper.encode({ :payload => payload })}")  # set it to the request with the Bearer prefix
          end

          req.body = payload.to_json
          res = http.request(req)  # get the response
          data = res.body  # and take its body
        rescue => ex
          raise ex.message
        end

        json_data = JSON.parse(data)
        return get_response_uri(json_data)
      end

      # get the response url
      def get_response_uri(json_data)

        file_result = json_data

        error_element = file_result['error']
        if error_element != nil  # if an error occurs
          raise 'ConvertError: ErrorCode = ' + error_element.to_s
        end

        is_end_convert = file_result['endConvert']  # check if the conversion is completed

        result_percent = 0  # the conversion percentage
        response_uri = ''

        if is_end_convert  # if the conversion is completed

          file_url_element = file_result['fileUrl']

          if file_url_element == nil  # and the file url doesn't exist
            raise 'Invalid answer format'  # get ann error message
          end

          response_uri = file_url_element  # otherwise, get the file url
          result_percent = 100

        else  # if the conversion isn't completed

          percent_element = file_result['percent']  # get the percentage value

          if percent_element != nil
            result_percent = percent_element.to_i
          end

          result_percent = result_percent >= 100 ? 99 : result_percent

        end

        return result_percent, response_uri
      end
    end
end