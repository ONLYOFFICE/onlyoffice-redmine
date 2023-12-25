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

# TODO: create a generic error response structure and handle it in the start
# method (check if the response contains the error property with non-zero value)

require "json"
require "net/http"
require "uri"
require "sorbet-runtime"
require_relative "../logger"
require_relative "command"
require_relative "conversion"
require_relative "health_check"

module OnlyOffice; end

module OnlyOffice::API
  class Client
    extend T::Sig

    sig { returns(String) }
    attr_reader :base_url

    sig { returns(CommandService) }
    attr_reader :command

    sig { returns(ConversionService) }
    attr_reader :conversion

    sig { returns(HealthCheckService) }
    attr_reader :health_check

    sig { params(base_url: String, http: T.nilable(Net::HTTP)).void }
    def initialize(base_url:, http: nil)
      @base_url = base_url

      unless http
        uri = URI(base_url)
        http = Net::HTTP.new(uri.hostname, uri.port)
        http = T.let(http, Net::HTTP)
        http.use_ssl = uri.scheme == "https"
      end
      @http = T.let(http, Net::HTTP)

      command = CommandService.new(client: self)
      @command = T.let(command, CommandService)

      conversion = ConversionService.new(client: self)
      @conversion = T.let(conversion, ConversionService)

      health_check = HealthCheckService.new(client: self)
      @health_check = T.let(health_check, HealthCheckService)
    end

    sig { returns(Net::HTTP) }
    def http
      @http.clone
    end

    sig { returns(Net::HTTP) }
    protected def http!
      @http
    end

    sig do
      params(
        secret: String,
        algorithm: String,
        header: T.nilable(T::Hash[T.any(String, Symbol), T.untyped]),
        http_header: String
      )
        .returns(Client)
    end
    def with_jwt(secret, algorithm, header = nil, http_header = "Authorization")
      client = copy

      header =
        begin
          base = {
            alg: algorithm,
            typ: "JWT"
          }
          if header
            merged = base.merge(header)
            merged.transform_keys(&:to_sym)
          else
            base
          end
        end

      callback = @http.method(:request)
      client.http!.define_singleton_method(:request) do |request, body = nil, &block|
        request = T.let(request, Net::HTTPRequest)

        # TODO: add handling of a body that passed without a request instance.

        unless request.body
          return callback.call(request, body, &block)
        end

        payload = JSON.parse(request.body)

        case request.method
        when Net::HTTP::Get::METHOD
          header_payload = {
            payload: payload
          }
          header_token = JWT.encode(header_payload, secret, algorithm, header)
          request[http_header] = "Bearer #{header_token}"
          request.body = nil
        when Net::HTTP::Post::METHOD
          body_token = JWT.encode(payload, secret, algorithm, header)
          body_payload = {
            token: body_token
          }
          request.body = body_payload.to_json
        else
          # continue
        end

        callback.call(request, body, &block)
      end

      client
    end

    sig { returns(Client) }
    private def copy
      self.class.new(base_url: @base_url.dup, http: http)
    end

    sig do
      params(path: String, body: T.nilable(T::Hash[String, T.untyped]))
        .returns(Net::HTTPRequest)
    end
    def get(path, body = nil)
      request(Net::HTTP::Get, path, body)
    end

    sig do
      params(path: String, body: T.nilable(T::Hash[String, T.untyped]))
        .returns(Net::HTTPRequest)
    end
    def post(path, body = nil)
      request(Net::HTTP::Post, path, body)
    end

    sig do
      params(
        method: T.class_of(Net::HTTPRequest),
        path: String,
        body: T.nilable(T::Hash[String, T.untyped])
      )
        .returns(Net::HTTPRequest)
    end
    def request(method, path, body = nil)
      uri = URI.join(@base_url, path)
      request = method.new(uri)
      request["Accept"] = "application/json"

      if body
        request["Content-Type"] = "application/json"
        request.body = body.to_json
      end

      request
    end

    sig do
      params(request: Net::HTTPRequest)
        .returns([T.untyped, Net::HTTPResponse])
    end
    def start(request)
      logger.info("Starting #{request.method} #{request.uri} #{request.to_hash} #{request.body}")
      response = @http.start do
        response = @http.request(request)
      end
      response = T.let(response, Net::HTTPResponse)
      logger.info("#{response.code} #{response.message} #{response.to_hash} #{response.body}")

      body = JSON.parse(response.body)
      [body, response]
    end

    sig { returns(Logger) }
    private def logger
      OnlyOffice.logger
    end
  end
end
