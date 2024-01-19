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

require "pathname"
require "sorbet-runtime"

module OnlyOffice; end

module OnlyOffice::Resources
  module Resource
    extend T::Sig
    extend T::Helpers
    include Kernel
    abstract!

    sig { overridable.returns(Pathname) }
    def directory
      current = Pathname(T.must(__dir__))
      resources = current.join("../../resources")
      resources.cleanpath
    end
  end
end
