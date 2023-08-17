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

# typed: true
# frozen_string_literal: true

require_relative "../../lib/onlyoffice"

class FileUtility
  @@resource_manager = OnlyOffice::Resource::Manager.new
  @@format_manager = OnlyOffice::Format::Manager.new(
    resource_manager: @@resource_manager
  )

  class << self
    def format_manager
      @@format_manager
    end

    def get_all_available_formats
      format_manager = T.let(@@format_manager, OnlyOffice::Format::Managering)
      formats =
        format_manager.documents +
        format_manager.presentations +
        format_manager.spreadsheets
      formats.map(&:extension)
    end

    def get_file_type(file_name)
      format_manager = T.let(@@format_manager, OnlyOffice::Format::Managering)
      extension = File.extname(file_name).downcase
      format = format_manager.define(extension)
      return format_manager.default.type unless format
      format.type
    end

    def is_openable(attachment)
      format_manager = T.let(@@format_manager, OnlyOffice::Format::Managering)
      extension = File.extname(attachment.disk_filename).downcase
      format = format_manager.define(extension)
      return false unless format
      format_manager.documents.include?(format) ||
        format_manager.presentations.include?(format) ||
        format_manager.spreadsheets.include?(format)
    end

    def is_editable(attachment)
      format_manager = T.let(@@format_manager, OnlyOffice::Format::Managering)
      extension = File.extname(attachment.disk_filename).downcase

      format = format_manager.define(extension)
      return false unless format

      # Add fillable for backward compatibility.
      format_manager.editable.include?(format) ||
        format_manager.fillable.include?(format)
    end

    def can_create(ext)
      format_manager = T.let(@@format_manager, OnlyOffice::Format::Managering)
      extension = ".#{ext.downcase}"
      format = format_manager.define(extension)
      return false unless format
      format_manager.creatable.include?(format)
    end

    def get_mimetype(ext)
      format_manager = T.let(@@format_manager, OnlyOffice::Format::Managering)
      extension = ext.downcase
      format = format_manager.define(extension)
      return format_manager.default.mime.first unless format
      format.mime.first
    end

    def format_supported(ext)
      format_manager = T.let(@@format_manager, OnlyOffice::Format::Managering)
      extension = ".#{ext.downcase}"
      format = format_manager.define(extension)
      return [] unless format&.convertible?
      format.convert
    end

  end
end
