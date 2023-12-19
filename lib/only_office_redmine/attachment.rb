#
# (c) Copyright Ascensio System SIA 2023
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

# typed: true
# frozen_string_literal: true

module OnlyOfficeRedmine
  class Attachment
    extend T::Sig

    sig { params(id: Integer).returns(T.nilable(Attachment)) }
    def self.find(id)
      attachment = ::Attachment.find(id)
      unless attachment
        return nil
      end
      Attachment.new(attachment:)
    end

    sig { params(attachment: ::Attachment).void }
    def initialize(attachment:)
      @attachment = attachment
    end

    sig { returns(::Attachment) }
    def internal
      @attachment
    end

    sig { returns(Integer) }
    def id
      @attachment.id
    end

    sig { returns(String) }
    def token
      @attachment.token
    end

    sig { returns(String) }
    def filename
      @attachment.filename
    end

    sig { returns(String) }
    def diskfile
      @attachment.diskfile
    end

    sig { returns(Integer) }
    def filesize
      @attachment.filesize
    end

    sig { returns(User) }
    def author
      User.new(user: @attachment.author)
    end

    sig { returns(Time) }
    def created_on
      @attachment.created_on
    end

    sig { returns(String) }
    def description
      @attachment.description
    end

    sig { returns(T.nilable(String)) }
    def content_type
      @attachment.content_type
    end

    sig { params(attributes: T.untyped).returns(Attachment) }
    def copy(attributes = nil)
      attachment = @attachment.copy(attributes)
      Attachment.new(attachment:)
    end

    sig { params(file: ActionDispatch::Http::UploadedFile).void }
    def file=(file)
      @attachment.file = file
    end

    sig { void }
    def files_to_final_location
      @attachment.files_to_final_location
    end

    sig { returns(T::Boolean) }
    def save
      @attachment.save
    end

    sig { void }
    def delete_from_disk
      @attachment.delete_from_disk
    end

    sig { returns(T.nilable(OnlyOfficeRedmine::Container)) }
    def container
      container = @attachment.container
      unless container
        return nil
      end
      OnlyOfficeRedmine::GenericContainer.from_internal(container)
    end

    sig { params(user: User).returns(T::Boolean) }
    def viewable?(user)
      format = self.format
      unless format
        return false
      end
      @attachment.readable? &&
        @attachment.visible?(user.internal) &&
        format.viewable?
    end

    sig { params(user: User).returns(T::Boolean) }
    def editable?(user)
      format = self.format
      unless format
        return false
      end
      @attachment.readable? &&
        @attachment.editable?(user.internal) &&
        format.editable?
    end

    sig { params(user: User).returns(T::Boolean) }
    def fillable?(user)
      format = self.format
      unless format
        return false
      end
      @attachment.readable? &&
        @attachment.editable?(user.internal) &&
        format.fillable?
    end

    sig { params(user: User).returns(T::Boolean) }
    def convertible?(user)
      format = self.format
      unless format
        return false
      end
      @attachment.readable? &&
        @attachment.visible?(user.internal) &&
        format.convertible?
    end

    sig { returns(T::Array[String]) }
    def convertible_to
      format = self.format
      unless format && format.convertible?
        return []
      end
      format.convert
    end

    sig { returns(T.nilable(OnlyOffice::Resources::Format)) }
    def format
      if defined?(@format)
        return @format
      end

      extension = self.extension
      unless extension
        @format = nil
        return @format
      end

      formats = OnlyOfficeRedmine::Resources::Formats.read
      @format = formats.all.find do |format|
        format.extension == extension
      end

      @format
    end

    sig { returns(String) }
    def name
      extension = File.extname(@attachment.filename)
      @attachment.filename.sub(extension, "")
    end

    sig { returns(T.nilable(String)) }
    def extension
      name = @attachment.disk_filename
      unless name
        return nil
      end
      extension = File.extname(name)
      extension.downcase
    end

    sig { params(user: User).returns(OnlyOffice::APP::Config) }
    def app_config(user)
      format = self.format

      config = OnlyOffice::APP::Config.new
      if format
        config.document_type = format.type
      end

      document = OnlyOffice::APP::Config::Document.new(
        key: token,
        title: filename,
        permissions: OnlyOffice::APP::Config::Permissions.new(
          edit: editable?(user),
          fill_forms: fillable?(user)
        )
      )
      if format
        document.file_type = format.name
      end

      config.document = document
      config
    end
  end
end
