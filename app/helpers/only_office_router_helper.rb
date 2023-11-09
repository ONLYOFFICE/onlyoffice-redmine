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

module OnlyOfficeRouterHelper
  extend T::Sig
  extend T::Helpers
  include Kernel
  abstract!

  class AttachmentPayload < T::Struct
    prop :user_id, Integer
  end

  sig do
    params(attachment_id: Integer, payload: AttachmentPayload)
      .returns(String)
  end
  private def onlyoffice_download_attachment_url(attachment_id, payload)
    uri = onlyoffice_download_attachment_uri(attachment_id, payload)
    uri.to_s
  end

  sig do
    params(attachment_id: Integer, payload: AttachmentPayload)
      .returns(URI::Generic)
  end
  private def onlyoffice_download_attachment_uri(attachment_id, payload)
    ac = T.cast(self, ApplicationController)
    url = ac.helpers.onlyoffice_raw_download_attachment_url(attachment_id)
    uri = URI(url)
    uri.query = URI.encode_www_form(payload.serialize)
    uri
  end

  sig do
    params(attachment_id: Integer, payload: AttachmentPayload)
      .returns(String)
  end
  private def onlyoffice_callback_attachment_url(attachment_id, payload)
    uri = onlyoffice_callback_attachment_uri(attachment_id, payload)
    uri.to_s
  end

  sig do
    params(attachment_id: Integer, payload: AttachmentPayload)
      .returns(URI::Generic)
  end
  private def onlyoffice_callback_attachment_uri(attachment_id, payload)
    ac = T.cast(self, ApplicationController)
    url = ac.helpers.onlyoffice_raw_callback_attachment_url(attachment_id)
    uri = URI(url)
    uri.query = URI.encode_www_form(payload.serialize)
    uri
  end
end
