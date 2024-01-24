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

module OnlyOfficeRedmine
  class Error < StandardError
    class << self
      extend T::Sig

      sig { returns(Error) }
      attr_reader :not_found

      sig { returns(Error) }
      attr_reader :unauthorized

      sig { returns(Error) }
      attr_reader :forbidden

      sig { returns(Error) }
      attr_reader :unsupported

      sig { returns(Error) }
      attr_reader :internal
    end

    @not_found    = T.let(new(message: "Not Found"),    Error)
    @unauthorized = T.let(new(message: "Unauthorized"), Error)
    @forbidden    = T.let(new(message: "Forbidden"),    Error)
    @unsupported  = T.let(new(message: "Unsupported"),  Error)
    @internal     = T.let(new(message: "Internal"),     Error)
  end
end
