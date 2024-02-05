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

module OnlyOfficeUserHelper
  extend T::Sig
  extend T::Helpers
  include Kernel
  abstract!

  # https://bugzilla.onlyoffice.com/show_bug.cgi?id=66273
  sig { void }
  private def resetup_user
    ac = T.cast(self, ApplicationController)

    uri = URI(ac.request.url)
    query = uri.query
    unless query
      logger.error("The query string couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    form = URI.decode_www_form(query)
    pair = form.assoc("user_id")
    unless pair
      logger.error("The user_id parameter couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    id = Integer(pair.last, 10)
    user = ::User.find(id)
    unless user
      logger.error("The user (#{id}) couldn't be found")
      raise OnlyOfficeRedmine::Error.not_found
    end

    User.current = user
    logger.info("The current user has been changed to #{User.current.login} (id=#{User.current.id})")
  end
end
