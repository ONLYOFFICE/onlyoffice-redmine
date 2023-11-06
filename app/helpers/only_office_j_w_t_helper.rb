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

module OnlyOfficeJWTHelper
  extend T::Sig
  extend T::Helpers
  include Kernel
  abstract!

  sig { void }
  private def verify_jwt_token
    ac = T.cast(self, ApplicationController)

    settings = OnlyOfficeRedmine::Settings.current

    unless settings.jwt.enabled
      return
    end

    decoder = jwt_decoder(settings)

    begin
      case ac.request.method
      when Net::HTTP::Get::METHOD
        header = ac.request.headers[settings.jwt.http_header]
        payload = jwt_decode_header(header, &decoder)
      when Net::HTTP::Post::METHOD
        input = ac.request.get_header("rack.input")
        payload = jwt_decode_body(input, &decoder)
      else
        raise OnlyOfficeRedmine::Error.unauthorized
      end
    rescue JWT::DecodeError
      raise OnlyOfficeRedmine::Error.unauthorized
    end

    unless payload
      raise OnlyOfficeRedmine::Error.unauthorized
    end

    content_length = payload.bytesize
    decoded_input = StringIO.new(payload)

    ac.request.set_header("CONTENT_LENGTH", content_length)
    ac.request.set_header("rack.input", decoded_input)
  end

  Decoder = T.type_alias do
    T.proc
     .params(token: String)
     .returns([T::Hash[T.untyped, T.untyped], T.untyped])
  end

  sig do
    params(header: T.nilable(String), decoder: Decoder)
      .returns(T.nilable(String))
  end
  private def jwt_decode_header(header, &decoder)
    unless header
      return nil
    end

    token = header["Bearer ".length, header.length - 1]
    unless token
      return nil
    end

    data, = decoder.call(token)
    payload = data["payload"]
    unless payload
      return nil
    end

    payload.to_json
  end

  sig do
    params(input: T.any(IO, StringIO), decoder: Decoder)
      .returns(T.nilable(String))
  end
  private def jwt_decode_body(input, &decoder)
    if input.respond_to?(:rewind)
      input.rewind
    end

    json = input.read
    unless json
      return nil
    end

    data = JSON.parse(json)

    token = data["token"]
    token = T.let(token, T.nilable(String))
    unless token
      return nil
    end

    payload, = decoder.call(token)
    payload.to_json
  end

  sig { params(settings: OnlyOfficeRedmine::Settings).returns(Decoder) }
  private def jwt_decoder(settings)
    lambda do |token|
      JWT.decode(
        token,
        settings.jwt.secret,
        true,
        {
          algorithm: settings.jwt.algorithm
        }
      )
    end
  end

  Encoder = T.type_alias do
    T.proc
     .params(payload: T::Hash[T.untyped, T.untyped])
     .returns(T::Hash[T.untyped, T.untyped])
  end

  sig do
    params(payload: T::Hash[T.untyped, T.untyped], encoder: Encoder)
      .returns(String)
  end
  private def jwt_encode_payload(payload, &encoder)
    payload = payload.dup
    payload["token"] = encoder.call(payload)
    payload.to_json
  end

  sig { params(settings: OnlyOfficeRedmine::Settings).returns(Encoder) }
  private def jwt_encoder(settings)
    lambda do |payload|
      JWT.encode(
        payload,
        settings.jwt.secret,
        settings.jwt.algorithm,
        {
          algorithm: settings.jwt.algorithm
        }
      )
    end
  end
end
