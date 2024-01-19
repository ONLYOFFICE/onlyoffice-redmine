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

module OnlyOfficeErrorHelper
  extend T::Sig
  extend T::Helpers
  include Kernel
  abstract!

  sig { params(error: OnlyOfficeRedmine::Error).returns(T.untyped) }
  private def handle_error(error)
    case error
    when OnlyOfficeRedmine::Error.not_found
      render_404
    when OnlyOfficeRedmine::Error.unauthorized
      raise Unauthorized
    when OnlyOfficeRedmine::Error.forbidden
      render_403
    when OnlyOfficeRedmine::Error.unsupported
      render_error({ message: OnlyOfficeRedmine::Error.unsupported.message })
    when OnlyOfficeRedmine::Error.internal
      render_error({ message: OnlyOfficeRedmine::Error.internal.message })
    else
      # nothing
    end
  end
end
