#
# (c) Copyright Ascensio System SIA 2024
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

require "sorbet-runtime"
require_relative "service"

module OnlyOffice; end

module OnlyOffice::API
  class CommandService < Service; end

  class CommandVersion < T::Struct
    prop :version, String
  end

  class CommandService
    sig { returns([T.any(CommandVersion, CommandError), Net::HTTPResponse]) }
    def version
      command = Command.new(c: "version")
      execute(command)
    end
  end

  class Command < T::Struct
    prop :c, String
  end

  CommandResult = T.type_alias do
    CommandVersion
  end

  class CommandError < T::Struct
    prop :error, Integer
  end

  class CommandService
    sig do
      params(command: Command)
        .returns([T.any(CommandResult, CommandError), Net::HTTPResponse])
    end
    def execute(command)
      request = command.serialize
      http_request = @client.post("coauthoring/CommandService.ashx", request)
      response, http_response = @client.start(http_request)

      begin
        case command.c
        when "version"
          version = CommandVersion.from_hash(response)
          return [version, http_response]
        else
          # continue
        end
      rescue StandardError
        # continue
      end

      error = CommandError.from_hash(response)
      [error, http_response]
    end
  end

  class CommandError
    extend T::Sig

    sig { returns(String) }
    def description
      case error
      when 0
        "No errors"
      when 1
        "Document key is missing or no document with such key could be found"
      when 2
        "Callback url not correct"
      when 3
        "Internal server error"
      when 4
        "No changes were applied to the document before the forcesave command was received"
      when 5
        "Command not correct"
      when 6
        "Invalid token"
      else
        "Unknown error code"
      end
    end
  end
end
