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

class CallbackHelper

  @@commandUrl = "coauthoring/CommandService.ashx"

  class << self

    def read_body(request)
      callback_body = request.body.read
      if callback_body.empty? || callback_body == nil
        return nil
      end

      data = JSON.parse(callback_body)

      if JwtHelper.is_enabled
        inHeader = false
        token = nil
        jwtHeader = JwtHelper.jwt_header
        if data["token"]
          token = JwtHelper.decode(data["token"])
        elsif request.headers[jwtHeader]
          hdr = request.headers[jwtHeader]
          hdr.slice!(0, "Bearer ".length)
          token = JwtHelper.decode(hdr)
          inHeader = true
        else
          raise "Expected JWT"
        end

        if !token || token.eql?("")
          raise "Invalid JWT signature"
        end

        data = JSON.parse(token)

        if inHeader
          data = data["payload"]
        end
      end

      return data

    end

    def save_from_uri(directory, filename, download_url)
      res = do_request(FileUtility.replace_doc_edito_url_to_internal(download_url))
      data = res.body

      uri = URI.parse(FileUtility.replace_doc_edito_url_to_internal(download_url))
      http = Net::HTTP.new(uri.host, uri.port)
      check_cert(uri.to_s, http)

      if data == nil
        raise 'stream is null'
      end

      FileUtils.mkdir_p(directory)
      File.open(File.join(directory, filename), 'wb') do |file|
        file.write(data)
      end
    end

    def do_request(url, force = false)
      uri = URI.parse(force ? url : FileUtility.replace_doc_edito_url_to_internal(url))
      http = Net::HTTP.new(uri.host, uri.port)

      check_cert(uri.to_s, http)

      req = Net::HTTP::Get.new(uri)
      res = http.request(req)
      return res
    end

    # send the command request

    def command_request(method, key = nil, url = nil, secret = nil)
      editor_base_url = url.nil? ? Config.get_config("oo_address") : url
      document_command_url = editor_base_url + @@commandUrl

      # create a payload object with the method and key
      if method == "version"
        payload = {
            :c => method,
          }
      else
        payload = {
            :c => method,
            :key => key
          }
      end

      data = nil
      begin
        uri = URI.parse(document_command_url)  # parse the document command url
        http = Net::HTTP.new(uri.host, uri.port)  # create a connection to the http server

        check_cert(uri.to_s, http)

        req = Net::HTTP::Post.new(uri.request_uri)  # create the post request
        req.add_field("Content-Type", "application/json")  # set headers
        JwtHelper.init
        if !secret.nil? || JwtHelper.is_enabled
          payload["token"] = JwtHelper.encode(payload, secret)  # get token and save it to the payload
          demo_header = Config.get_config("jwtHeader")
          jwtHeader = demo_header.nil? ? JwtHelper.jwt_header : demo_header  # get signature authorization header
          req.add_field(jwtHeader, "Bearer #{JwtHelper.encode({ :payload => payload }, secret)}")  # set it to the request with the Bearer prefix
        end

        req.body = payload.to_json   # convert the payload object into the json format
        res = http.request(req)  # get the response
        data = res.body  # and take its body
      rescue => ex
          raise ex.message
      end

      json_data = JSON.parse(data)  # convert the response body into the json format
      return json_data
    end

    def delete_diskfile_by_digest(digest, path)
      attachments = Attachment.where(digest: digest)
      if attachments.length.eql?(0)
        File.delete(path) if File.exist?(path)
      end
    end

    def process_save(callback_json, attachment)
      download_uri = FileUtility.replace_doc_edito_url_to_internal(callback_json['url'])
      if (download_uri.eql?(nil))
        saved = 1
        return saved
      end

      saved = 1
      begin
        old_digest = attachment.digest
        old_diskfile = attachment.diskfile
        callback_date = DateTime.now

        new_date = callback_date.year.to_s[2,4] + callback_date.month.to_s + callback_date.day.to_s
        new_time = callback_date.hour.to_s + callback_date.minute.to_s + callback_date.second.to_s

        new_disk_directory = callback_date.year.to_s + "/" + ("%02d" % callback_date.month.to_s)
        new_absolute_directory = attachment.diskfile.split("files")[0] + "files/" + new_disk_directory
        new_filename = new_date + new_time + "_" + attachment.disk_filename.split("_")[1]

        save_from_uri(new_absolute_directory, new_filename, download_uri)

        new_digest = Digest::SHA256.new
        new_filesize = attachment.filesize
        File.open(File.join(new_absolute_directory, new_filename), 'rb') do |file|
          while buffer = file.read(8192)
            new_digest.update(buffer)
            new_filesize = file.size
          end
        end

        Attachment.update(attachment.id, :filesize => new_filesize, :digest => new_digest, :disk_filename => new_filename,
                          :disk_directory => new_disk_directory, :created_on => callback_date)

        delete_diskfile_by_digest(old_digest, old_diskfile)

        saved = 0
      rescue => error
        raise error.message
      end

      return saved
    end

    def check_cert(uri, http)
      if uri.start_with? 'https'
        http.use_ssl = true
        if Setting.plugin_onlyoffice_redmine["check_cert"].eql?("on")
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      end
    end
  
  end

end