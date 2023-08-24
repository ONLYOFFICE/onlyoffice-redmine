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

module OnlyOffice::Resource; end

module OnlyOffice::Resource::Managering
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.returns(Pathname) }
  def directory; end
end

class OnlyOffice::Resource::Manager
  extend T::Sig
  include OnlyOffice::Resource::Managering

  sig { override.returns(Pathname) }
  def directory
    current_directory = Pathname(T.must(__dir__))
    directory = current_directory.join("..", "..", "resources")
    directory.cleanpath
  end
end
