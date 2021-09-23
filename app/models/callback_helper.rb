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

    def process_save(callback_json, attachment)
      download_uri = callback_json['url']
      if (download_uri.eql?(nil))
        saved = 1
        return saved
      end

      new_file_name = attachment.disk_filename
      cur_ext = File.extname(attachment.filename).downcase
      download_ext = File.extname(download_uri).downcase

      saved = 1
      begin
        storage_path = DocumentHelper.storage_path(attachment, new_file_name)
        hist_dir = DocumentHelper.history_path(storage_path)
        ver_dir = DocumentHelper.version_path(hist_dir, DocumentHelper.get_attachment_version(hist_dir, "save").to_s)

        FileUtils.mkdir_p(ver_dir)
        FileUtils.move(DocumentHelper.storage_path(attachment, attachment.disk_filename), File.join(ver_dir, "prev#{cur_ext}"))
        save_from_uri(attachment.diskfile, download_uri)

        if callback_json["changesurl"]
          save_from_uri(File.join(ver_dir, "diff.zip"), callback_json["changesurl"])
        end

        history_data = callback_json["changeshistory"]
        if !history_data
          history_data = callback_json["history"].to_json
        end
        if history_data
          File.open(File.join(ver_dir, "changes.json"), "wb") do |file|
            file.write(history_data)
          end
        end

        File.open(File.join(ver_dir, "key.txt"), "wb") do |file|
          file.write(data["key"])
        end

        saved = 0
      rescue StandardError => error
        saved = 1
      end

      return saved
    end

  end

end