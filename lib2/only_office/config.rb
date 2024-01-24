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

module OnlyOffice
  class Config
    class SSL
      extend T::Sig

      sig { returns(T::Boolean) }
      def verification_disabled
        @verify_mode == OpenSSL::SSL::VERIFY_NONE
      end
    end

    class JWT
      sig { params(header: String).returns(T.nilable(String)) }
      def decode_header(header)
        token = header["Bearer ".length, header.length - 1]
        unless token
          return nil
        end

        data, = decode(token)
        payload = data["payload"]
        unless payload
          return nil
        end

        payload.to_json
      end

      sig { params(input: T.any(IO, StringIO)).returns(T.nilable(String)) }
      def decode_body(input)
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

        payload, = decode(token)
        payload.to_json
      end

      sig { params(url: String).returns(T.nilable(String)) }
      def decode_url(url)
        uri = URI(url)

        query = uri.query
        unless query
          return nil
        end

        form = URI.decode_www_form(query)

        pair = form.assoc("token")
        unless pair
          return nil
        end

        token = pair.last
        data, = decode(token)

        url = data["url"]
        url = T.let(url, T.nilable(String))
        unless url
          return nil
        end

        form.delete(["token", token])
        uri.query = URI.encode_www_form(form)

        # If the uri only has a token in the query, the uri will end with
        # the `?` after removing the token.
        unless url == uri.to_s || "#{url}?" == uri.to_s
          return nil
        end

        url
      end

      sig do
        params(token: String)
          .returns([T::Hash[T.untyped, T.untyped], T.untyped])
      end
      def decode(token)
        ::JWT.decode(token, secret, true, { algorithm: algorithm })
      end

      sig { params(payload: T::Hash[T.untyped, T.untyped]).returns(String) }
      def encode_payload(payload)
        payload = payload.dup
        payload["token"] = encode(payload)
        payload.to_json
      end

      sig { params(url: String).returns(String) }
      def encode_url(url)
        uri = URI(url)
        query = uri.query || ""
        form = URI.decode_www_form(query)
        token = encode({ url: url })
        form.append(["token", token])
        uri.query = URI.encode_www_form(form)
        uri.to_s
      end

      sig { params(payload: T.untyped).returns(String) }
      def encode(payload)
        ::JWT.encode(payload, secret, algorithm, { algorithm: algorithm })
      end
    end
  end
end
