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

module Blocks; end
require_relative "_blocks/helpers"
require_relative "_blocks/assets"
require_relative "_blocks/banner"

module Blocks::Edit; end
require_relative "_blocks/edit/icon"
require_relative "_blocks/edit/contextual"

module Blocks::View; end
require_relative "_blocks/view/icon"
require_relative "_blocks/view/contextual"

module Blocks::Convert; end
require_relative "_blocks/convert/icon"
require_relative "_blocks/convert/contextual"

require_relative "_blocks/attachments"

module Blocks::New; end
require_relative "_blocks/new/anchor"
