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
    settings = OnlyOfficeRedmine::Settings.current
    if settings.trial.enabled
      settings = settings.with_trial
    end
    if settings.jwt.enabled
      verify_general_jwt_token(settings.jwt)
    end
    if settings.fallback_jwt.enabled
      verify_fallback_jwt_token(settings.fallback_jwt)
    end
    nil
  end

  sig { params(jwt: T.nilable(OnlyOffice::Config::JWT)).void }
  private def verify_general_jwt_token(jwt = nil)
    ac = T.cast(self, ApplicationController)

    unless jwt
      settings = OnlyOfficeRedmine::Settings.current
      if settings.trial.enabled
        settings = settings.with_trial
      end
      unless settings.jwt.enabled
        return nil
      end
      jwt = settings.jwt
    end

    begin
      case ac.request.method
      when Net::HTTP::Get::METHOD
        header = ac.request.headers[jwt.http_header]
        if header
          payload = jwt.decode_header(header)
        end
      when Net::HTTP::Post::METHOD
        input = ac.request.get_header("rack.input")
        payload = jwt.decode_body(input)
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

  sig { params(jwt: T.nilable(OnlyOffice::Config::JWT)).void }
  private def verify_fallback_jwt_token(jwt = nil)
    ac = T.cast(self, ApplicationController)

    unless jwt
      settings = OnlyOfficeRedmine::Settings.current
      if settings.trial.enabled
        settings = settings.with_trial
      end
      unless settings.fallback_jwt.enabled
        return nil
      end
      jwt = settings.fallback_jwt
    end

    begin
      url = jwt.decode_url(ac.request.url)
    rescue JWT::DecodeError
      raise OnlyOfficeRedmine::Error.unauthorized
    end

    unless url
      raise OnlyOfficeRedmine::Error.unauthorized
    end

    nil
  end
end
