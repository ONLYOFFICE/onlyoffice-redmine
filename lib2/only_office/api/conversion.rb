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

module OnlyOffice::API
  class ConversionComplete
    extend T::Sig

    sig { returns(T.nilable(OnlyOffice::Resources::Format)) }
    def file_format
      formats = OnlyOfficeRedmine::Resources::Formats.read
      formats.all.find do |format|
        format.name == file_type
      end
    end
  end
end
