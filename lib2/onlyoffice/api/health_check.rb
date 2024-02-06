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
  class HealthCheckService < Service
    sig { returns([T::Boolean, Net::HTTPResponse]) }
    def check
      http_request = @client.get("healthcheck")
      response, http_response = @client.start(http_request)
      unless response.is_a?(TrueClass)
        return [false, http_response]
      end
      [response, http_response]
    end
  end
end
