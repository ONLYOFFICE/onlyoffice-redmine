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

module Blocks::Helpers
  extend T::Sig
  extend T::Helpers
  include Kernel
  abstract!

  # [Ruby on Rails Reference](https://api.rubyonrails.org/v6.1.0/classes/ActionView/Helpers.html)
  sig { abstract.returns(T.untyped) }
  def helpers; end

  # [Ruby on Rails Reference](https://api.rubyonrails.org/v6.1.0/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag)
  sig { params(url: String, multipart: T::Boolean).returns(T.untyped) }
  def helpers_form_tag(url = "#", multipart: true)
    lambda do |text|
      portalled = helpers.form_tag(url, multipart:) do
        text.html_safe
      end
      T.bind(self, Mustache)
      render(portalled)
    end
  end

  # [Redmine Reference: Helper](https://github.com/redmine/redmine/blob/5.0.0/app/helpers/application_helper.rb#L1677)
  sig { params(url: String).returns(String) }
  def helpers_image_tag(url)
    helpers.image_tag(url, plugin: "onlyoffice_redmine")
  end

  # [Redmine Reference: Helper](https://github.com/redmine/redmine/blob/5.0.0/app/helpers/application_helper.rb#L1657)
  sig { params(source: String).returns(String) }
  def helpers_stylesheet_link_tag(source)
    helpers.stylesheet_link_tag(source, plugin: "onlyoffice_redmine")
  end

  # [Redmine Reference: Helper](https://github.com/redmine/redmine/blob/5.0.0/app/helpers/application_helper.rb#L1691)
  sig { params(source: String).returns(String) }
  def javascript_include_tag(source)
    helpers.javascript_include_tag(source, plugin: "onlyoffice_redmine")
  end
end
