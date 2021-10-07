# Copyright (c) Ascensio System SIA 2021. All rights reserved.
# http://www.onlyoffice.com

class CallbackHelper

  class << self

    def read_body(request)
      callback_body = request.body.read
      if callback_body.empty? || callback_body == nil
        return nil
      end

      data = JSON.parse(callback_body)

      if JWTHelper.is_enabled
        inHeader = false
        token = nil
        jwtHeader = "Authorization"
        if data["token"]
          token = JWTHelper.decode(data["token"])
        elsif request.headers[jwtHeader]
          hdr = request.headers[jwtHeader]
          hdr.slice!(0, "Bearer ".length)
          token = JWTHelper.decode(hdr)
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

    def save_from_uri(path, download_url)
      uri = URI.parse(download_url)
      http = Net::HTTP.new(uri.host, uri.port)

      if download_url.start_with?('https')
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      req = Net::HTTP::Get.new(uri)
      res = http.request(req)
      data = res.body

      if data == nil
        raise 'stream is null'
      end

      File.open(path, 'wb') do |file|
        file.write(data)
      end
    end

    def delete_diskfile_by_digest(digest, path)
      attachments = Attachment.where(digest: digest)
      if attachments.length.eql?(0)
        File.delete(path) if File.exist?(path)
      end
    end

    def process_save(callback_json, attachment)
      download_uri = callback_json['url']
      if (download_uri.eql?(nil))
        saved = 1
        return saved
      end

      saved = 1
      begin
        old_digest = attachment.digest
        old_diskfile = attachment.diskfile
        callback_created_data = callback_json['history']['changes'][0]['created']
        new_year = callback_created_data.split("-")[0][2,4]
        new_date = new_year + callback_created_data.split("-")[1] + callback_created_data.split("-")[1].split(" ")[0]
        new_time = callback_created_data.split(" ")[1].split(":")[0] + callback_created_data.split(" ")[1].split(":")[1] + callback_created_data.split(" ")[1].split(":")[2]
        new_disk_directory = callback_created_data.split("-")[0] + "/" + callback_created_data.split("-")[1]
        new_absolute_directory = attachment.diskfile.split("files")[0] + "files/" + new_disk_directory
        new_filename = new_date + new_time + "_" + attachment.disk_filename.split("_")[1]

        save_from_uri(File.join(new_absolute_directory, new_filename), download_uri)

        new_digest = Digest::SHA256.new
        new_filesize = attachment.filesize
        File.open(File.join(new_absolute_directory, new_filename), 'rb') do |file|
          while buffer = file.read(8192)
            new_digest.update(buffer)
            new_filesize = file.size
          end
        end

        Attachment.update(attachment.id, :filesize => new_filesize, :digest => new_digest, :disk_filename => new_filename,
                          :disk_directory => new_disk_directory, :created_on => callback_created_data)

        delete_diskfile_by_digest(old_digest, old_diskfile)

        saved = 0
      rescue StandardError => error
        saved = 1
      end

      return saved
    end

  end

end