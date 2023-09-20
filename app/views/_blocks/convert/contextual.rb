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

module Blocks::Convert::Contextual
  extend T::Sig
  extend T::Helpers
  include Blocks::Convert::Icon
  abstract!

  sig { overridable.returns(T.nilable(String)) }
  def convert_url
    @convert_url ||= nil
  end

  sig { overridable.params(value: T.nilable(String)).void }
  def convert_url=(value)
    @convert_url = value
  end
end