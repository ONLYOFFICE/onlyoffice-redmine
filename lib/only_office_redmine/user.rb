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
  class User
    extend T::Sig

    sig { returns(User) }
    def self.current
      user = ::User.current
      new(user: user)
    end

    sig { params(id: Integer).returns(T.nilable(User)) }
    def self.find(id)
      user = ::User.find(id)
      unless user
        return nil
      end
      User.new(user: user)
    end

    sig { params(user: ::User).void }
    def initialize(user:)
      @user = user
    end

    sig { returns(::User) }
    def internal
      @user
    end

    sig { returns(Integer) }
    def id
      @user.id
    end

    sig do
      params(
        action: T.untyped,
        context: T.untyped,
        options: T.untyped,
        block: T.untyped
      )
        .returns(T::Boolean)
    end
    def allowed_to?(action, context, options = {}, &block)
      @user.allowed_to?(action, context, options, &block)
    end

    sig { returns(OnlyOffice::APP::Config) }
    def app_config
      OnlyOffice::APP::Config.new(
        editor_config: OnlyOffice::APP::Config::EditorConfig.new(
          user: OnlyOffice::APP::Config::User.new(
            id: @user.id.to_s,
            name: "#{@user.lastname} #{@user.firstname}"
          )
        )
      )
    end
  end
end
