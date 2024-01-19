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

module OnlyOffice::APP
  class Config < T::Struct
    class ReferenceData < T::Struct
      prop :file_key,    T.nilable(String), name: "fileKey"
      prop :instance_id, T.nilable(String), name: "instanceId"
    end

    class SharingSettings < T::Struct
      prop :is_link,     T.nilable(T::Boolean), name: "isLink"
      prop :permissions, T.nilable(String)
      prop :user,        T.nilable(String)
    end

    class Info < T::Struct
      prop :favorite,         T.nilable(T::Boolean)
      prop :folder,           T.nilable(String)
      prop :owner,            T.nilable(String)
      prop :sharing_settings, T.nilable(T::Array[SharingSettings]), name: "sharingSettings"
      prop :uploaded,         T.nilable(String)
    end

    class CommentGroup < T::Struct
      prop :edit,   T.nilable(T::Array[String])
      prop :remove, T.nilable(T::Array[String])
      prop :view,   T.nilable(T::Array[String])
    end

    class Permissions < T::Struct
      prop :chat,                       T.nilable(T::Boolean)
      prop :comment,                    T.nilable(T::Boolean)
      prop :comment_groups,             T.nilable(T::Array[CommentGroup])
      prop :copy,                       T.nilable(T::Boolean)
      prop :delete_comment_author_only, T.nilable(T::Boolean),             name: "deleteCommentAuthorOnly"
      prop :download,                   T.nilable(T::Boolean)
      prop :edit,                       T.nilable(T::Boolean)
      prop :edit_comment_author_only,   T.nilable(T::Boolean),             name: "editCommentAuthorOnly"
      prop :fill_forms,                 T.nilable(T::Boolean),             name: "fillForms"
      prop :modify_content_control,     T.nilable(T::Boolean),             name: "modifyContentControl"
      prop :modify_filter,              T.nilable(T::Boolean),             name: "modifyFilter"
      prop :print,                      T.nilable(T::Boolean)
      prop :protect,                    T.nilable(T::Boolean)
      prop :review,                     T.nilable(T::Boolean)
      prop :review_groups,              T.nilable(T::Array[String]),       name: "reviewGroups"
      prop :user_info_groups,           T.nilable(T::Array[String]),       name: "userInfoGroups"
    end

    class Document < T::Struct
      prop :file_type,      T.nilable(String),        name: "fileType"
      prop :key,            T.nilable(String)
      prop :reference_data, T.nilable(ReferenceData), name: "referenceData"
      prop :title,          T.nilable(String)
      prop :url,            T.nilable(String)
      prop :info,           T.nilable(Info)
      prop :permissions,    T.nilable(Permissions)
    end

    class CoEditing < T::Struct
      prop :mode,   T.nilable(String)
      prop :change, T.nilable(T::Boolean)
    end

    class Recent < T::Struct
      prop :folder, T.nilable(String)
      prop :title,  T.nilable(String)
      prop :url,    T.nilable(String)
    end

    class Template < T::Struct
      prop :image, T.nilable(String)
      prop :title, T.nilable(String)
      prop :url,   T.nilable(String)
    end

    class User < T::Struct
      prop :group, T.nilable(String)
      prop :id,    T.nilable(String)
      prop :name,  T.nilable(String)
    end

    class Anonymous < T::Struct
      prop :request, T.nilable(T::Boolean)
      prop :label,   T.nilable(String)
    end

    class Customer < T::Struct
      prop :address,   T.nilable(String)
      prop :info,      T.nilable(String)
      prop :logo,      T.nilable(String)
      prop :logo_dark, T.nilable(String), name: "logoDark"
      prop :mail,      T.nilable(String)
      prop :name,      T.nilable(String)
      prop :phone,     T.nilable(String)
      prop :www,       T.nilable(String)
    end

    class StructSpellcheck < T::Struct
      prop :mode, T.nilable(T::Boolean)
    end

    Spellcheck = T.type_alias do
      T.any(StructSpellcheck, T::Boolean)
    end

    class GenericSpellcheck < T::Struct
      prop :value, T.nilable(Spellcheck)
    end

    class Features < T::Struct
      prop :spellcheck, T.nilable(GenericSpellcheck)
    end

    class StructFeedback < T::Struct
      prop :url,     T.nilable(String)
      prop :visible, T.nilable(T::Boolean)
    end

    Feedback = T.type_alias do
      T.any(StructFeedback, T::Boolean)
    end

    class GenericFeedback < T::Struct
      prop :value, T.nilable(Feedback)
    end

    class StructGoBack < T::Struct
      prop :blank,         T.nilable(T::Boolean)
      prop :request_close, T.nilable(T::Boolean), name: "requestClose"
      prop :text,          T.nilable(String)
      prop :url,           T.nilable(String)
    end

    GoBack = T.type_alias do
      T.any(StructGoBack, T::Boolean)
    end

    class GenericGoBack < T::Struct
      prop :value, T.nilable(GoBack)
    end

    class Logo < T::Struct
      prop :image,      T.nilable(String)
      prop :image_dark, T.nilable(String), name: "imageDark"
      prop :url,        T.nilable(String)
    end

    class Review < T::Struct
      prop :hide_review_display, T.nilable(T::Boolean), name: "hideReviewDisplay"
      prop :hover_mode,          T.nilable(T::Boolean), name: "hoverMode"
      prop :review_display,      T.nilable(String),     name: "reviewDisplay"
      prop :show_review_changes, T.nilable(T::Boolean), name: "showReviewChanges"
      prop :track_changes,       T.nilable(T::Boolean), name: "trackChanges"
    end

    class Customization < T::Struct
      prop :anonymous,              T.nilable(Anonymous)
      prop :autosave,               T.nilable(T::Boolean)
      prop :comments,               T.nilable(T::Boolean)
      prop :compact_header,         T.nilable(T::Boolean),      name: "compactHeader"
      prop :compact_toolbar,        T.nilable(T::Boolean),      name: "compactToolbar"
      prop :compatible_features,    T.nilable(T::Boolean),      name: "compatibleFeatures"
      prop :customer,               T.nilable(Customer)
      prop :features,               T.nilable(Features)
      prop :feedback,               T.nilable(GenericFeedback)
      prop :force_save,             T.nilable(T::Boolean),      name: "forcesave"
      prop :go_back,                T.nilable(GenericGoBack),   name: "goback"
      prop :help,                   T.nilable(T::Boolean)
      prop :hide_notes,             T.nilable(T::Boolean),      name: "hideNotes"
      prop :hide_right_menu,        T.nilable(T::Boolean),      name: "hideRightMenu"
      prop :hide_rulers,            T.nilable(T::Boolean),      name: "hideRulers"
      prop :integration_mode,       T.nilable(String),          name: "integrationMode"
      prop :logo,                   T.nilable(Logo)
      prop :macros,                 T.nilable(T::Boolean)
      prop :macros_mode,            T.nilable(String),          name: "macrosMode"
      prop :mention_share,          T.nilable(T::Boolean),      name: "mentionShare"
      prop :plugins,                T.nilable(T::Boolean)
      prop :review,                 T.nilable(Review)
      prop :toolbar_hide_file_name, T.nilable(T::Boolean),      name: "toolbarHideFileName"
      prop :toolbar_no_tabs,        T.nilable(T::Boolean),      name: "toolbarNoTabs"
      prop :ui_theme,               T.nilable(String),          name: "uiTheme"
      prop :unit,                   T.nilable(String)
      prop :zoom,                   T.nilable(Integer)
    end

    class Embedded < T::Struct
      prop :embed_url,      T.nilable(String), name: "embedUrl"
      prop :fullscreen_url, T.nilable(String), name: "fullscreenUrl"
      prop :save_url,       T.nilable(String), name: "saveUrl"
      prop :share_url,      T.nilable(String), name: "shareUrl"
      prop :toolbar_docked, T.nilable(String), name: "toolbarDocked"
    end

    class Plugins < T::Struct
      prop :autostart,    T.nilable(T::Array[String])
      prop :plugins_data, T.nilable(T::Array[String]), name: "pluginsData"
      prop :url,          T.nilable(String)
    end

    class EditorConfig < T::Struct
      prop :action_link,   T.nilable(T::Hash[T.untyped, T.untyped]), name: "actionLink"
      prop :callback_url,  T.nilable(String),                        name: "callbackUrl"
      prop :co_editing,    T.nilable(CoEditing),                     name: "coEditing"
      prop :create_url,    T.nilable(String),                        name: "createUrl"
      prop :lang,          T.nilable(String)
      prop :location,      T.nilable(String)
      prop :mode,          T.nilable(String)
      prop :recent,        T.nilable(T::Array[Recent])
      prop :region,        T.nilable(String)
      prop :templates,     T.nilable(T::Array[Template])
      prop :user,          T.nilable(User)
      prop :customization, T.nilable(Customization)
      prop :embedded,      T.nilable(Embedded)
      prop :plugins,       T.nilable(Plugins)
    end

    prop :document_type, T.nilable(String),       name: "documentType"
    prop :height,        T.nilable(String)
    prop :type,          T.nilable(String)
    prop :width,         T.nilable(String)
    prop :document,      T.nilable(Document)
    prop :editor_config, T.nilable(EditorConfig), name: "editorConfig"

    class GenericSpellcheck
      extend T::Sig

      sig { params(hash: T.untyped, strict: T.untyped).returns(Spellcheck) }
      def self.from_hash(hash, strict = nil)
        case hash
        when TrueClass, FalseClass
          hash
        when Hash
          StructSpellcheck.from_hash(hash, strict)
        else
          raise ArgumentError, "#{hash.inspect} provided to from_hash"
        end
      end

      sig { params(strict: T.untyped).returns(T.untyped) }
      def serialize(strict = nil)
        case @value
        when TrueClass, FalseClass
          @value
        when StructSpellcheck
          @value.serialize(strict)
        else
          raise TypeError, "#{@value.inspect} stored in #{self.class.name}"
        end
      end
    end

    class GenericFeedback
      extend T::Sig

      sig { params(hash: T.untyped, strict: T.untyped).returns(Feedback) }
      def self.from_hash(hash, strict = nil)
        case hash
        when TrueClass, FalseClass
          hash
        when Hash
          StructFeedback.from_hash(hash, strict)
        else
          raise ArgumentError, "#{hash.inspect} provided to from_hash"
        end
      end

      sig { params(strict: T.untyped).returns(T.untyped) }
      def serialize(strict = nil)
        case @value
        when TrueClass, FalseClass
          @value
        when StructFeedback
          @value.serialize(strict)
        else
          raise TypeError, "#{@value.inspect} stored in #{self.class.name}"
        end
      end
    end

    class GenericGoBack
      extend T::Sig

      sig { params(hash: T.untyped, strict: T.untyped).returns(GoBack) }
      def self.from_hash(hash, strict = nil)
        case hash
        when TrueClass, FalseClass
          hash
        when Hash
          StructGoBack.from_hash(hash, strict)
        else
          raise ArgumentError, "#{hash.inspect} provided to from_hash"
        end
      end

      sig { params(strict: T.untyped).returns(T.untyped) }
      def serialize(strict = nil)
        case @value
        when TrueClass, FalseClass
          @value
        when StructGoBack
          @value.serialize(strict)
        else
          raise TypeError, "#{@value.inspect} stored in #{self.class.name}"
        end
      end
    end
  end
end
