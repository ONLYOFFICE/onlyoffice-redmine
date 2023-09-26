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

require_relative "blocks"

module Views; end

class Views::Mustache < Mustache
  extend T::Sig
  extend T::Helpers
  include Blocks::Helpers
  abstract!

  self.template_path = __dir__

  sig { override.returns(T.untyped) }
  attr_reader :helpers

  sig { overridable.params(helpers: T.untyped).void }
  def initialize(helpers:)
    super
    @helpers = helpers
  end

  def render(data = template, ctx = {})
    html = super(data, ctx)
    comment = Regexp.new("^\\s*?<!--[\\S\\s]*?-->\n{1,}")
    html.gsub(comment, "")
  end
end

module Views::Attachments; end
require_relative "attachments/show"

module Views::Documents; end
require_relative "documents/show"

module Views::Files; end
require_relative "files/index"

module Views::Issues; end
require_relative "issues/show"

module Views::News; end
require_relative "news/show"

module Views::OnlyOffice; end
require_relative "onlyoffice/editor"

module Views::OnlyOfficeConvert; end
require_relative "onlyoffice_convert/index"

module Views::OnlyOfficeCreate; end
require_relative "onlyoffice_create/new"

module Views::Settings; end
require_relative "settings/plugin"

module Views::Wiki; end
require_relative "wiki/show"
