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

require "sorbet-runtime"

module OnlyOffice; end

module OnlyOffice::STDLIB
  class String < ::String
    extend T::Sig

    # Converts a string that represents a boolean value to its corresponding
    # boolean value. It supports case-insensitive `true`, `t`, `yes`, `y`, and `1`
    # for the positive value, and `false`, `f`, `no`, `n`, and `0` for the
    # negative value. If the string doesn't match any of these values, returns the
    # default value.
    sig { params(default: T::Boolean).returns(T::Boolean) }
    def to_b(default: false)
      String.to_b(self, default: default)
    end

    sig { params(string: ::String, default: T::Boolean).returns(T::Boolean) }
    def self.to_b(string, default: false)
      case string.downcase
      when "true", "t", "yes", "y", "1"
        true
      when "false", "f", "no", "n", "0"
        false
      else
        default
      end
    end
  end
end
