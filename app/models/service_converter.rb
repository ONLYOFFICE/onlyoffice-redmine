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
    def get_converted_uri(doc_server_url, title, document_uri, from_ext, to_ext, document_revision_id, is_async, file_pass, lang = nil, secret = nil)

        from_ext = from_ext == nil ? File.extname(document_uri).downcase : from_ext  # get the current document extension

        # get the document key
        document_revision_id = document_revision_id.empty? ? document_uri : document_revision_id
        document_revision_id = generate_revision_id(document_revision_id)
  
        payload = {  # write all the conversion parameters to the payload
          :async => is_async,
          :url => document_uri,
          :outputtype => to_ext.delete('.'),
          :filetype => from_ext.delete('.'),
          :title => title,
          :key => document_revision_id,
          :password => file_pass,
          :region => lang
        }
  
        data = nil
        begin
          uri = URI.parse(doc_server_url + @@document_converter_url)  # create the request url
          http = Net::HTTP.new(uri.host, uri.port)  # create a connection to the http server
  
          CallbackHelper.check_cert(@@document_converter_url, http)
  
          http.read_timeout = @@convert_timeout
          req = Net::HTTP::Post.new(uri.request_uri)  # create the post request
          req.add_field("Accept", "application/json")  # set headers
          req.add_field("Content-Type", "application/json")
          JWTHelper.init
          if !secret.nil? || JWTHelper.is_enabled
            payload["token"] = JWTHelper.encode(payload, secret)  # get token and save it to the payload
            jwtHeader = "Authorization"  # get signature authorization header
            req.add_field(jwtHeader, "Bearer #{JWTHelper.encode({ :payload => payload }, secret)}")  # set it to the request with the Bearer prefix
          end
  
          req.body = payload.to_json
          res = http.request(req)  # get the response
          data = res.body  # and take its body
        rescue TimeoutError
          # try again
        rescue => ex
          raise ex.message
        end

        return data # get response url
      end

      # generate the document key value
      def generate_revision_id(expected_key)
  
        require 'zlib'
  
        if expected_key.length > 20  # check if the expected key length is greater than 20
          expected_key = (Zlib.crc32 expected_key).to_s  # calculate 32-bit crc value from the expected key and turn it into the string
        end
  
        key = expected_key.gsub(/[^0-9a-zA-Z.=]/, '_')
        key[(key.length - [key.length, 20].min)..key.length]  # the resulting key is of the length 20 or less

      end
  
      # create an error message for the error code
      def process_convert_service_responce_error(error_code)
  
        error_message = 'unknown error'
  
        # add an error message to the error message template depending on the error code
        case error_code
          when -8
            error_message = 'Error occurred in the ConvertService.ashx: Error document VKey'
          when -7
            error_message = 'Error occurred in the ConvertService.ashx: Error document request'
          when -6
            error_message = 'Error occurred in the ConvertService.ashx: Error database'
          when -5
            error_message = 'Error occurred in the ConvertService.ashx: Incorrect password'
          when -4
            error_message = 'Error occurred in the ConvertService.ashx: Error download error'
          when -3
            error_message = 'Error occurred in the ConvertService.ashx: Error convertation error'
          when -2
            error_message = 'Error occurred in the ConvertService.ashx: Error convertation timeout'
          when -1
            error_message = 'Error occurred in the ConvertService.ashx: Error convertation unknown'
          when 0
            # public const int c_nErrorNo = 0
          else
            error_message = 'ErrorCode = ' + error_code.to_s  # default value for the error message
        end
        raise error_message
  
      end
  
      # get the response url
      def get_response_uri(json_data)
  
        file_result = json_data
  
        error_element = file_result['error']
        if error_element != nil  # if an error occurs
          puts 'ConvertError: ErrorCode = ' + error_element
          process_convert_service_responce_error(error_element.to_i)  # get an error message
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