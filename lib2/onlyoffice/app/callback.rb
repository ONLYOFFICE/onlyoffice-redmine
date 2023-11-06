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

require "sorbet-runtime"

module OnlyOffice; end

module OnlyOffice::APP
  CallbackAction = T.type_alias do
    T.any(
      CallbackDisconnectAction,
      CallbackConnectAction,
      CallbackForceSaveAction
    )
  end

  class CallbackDisconnectAction < T::Struct
    prop :type,    Integer
    prop :user_id, String, name: "userid"
  end

  class CallbackConnectAction < T::Struct
    prop :type,    Integer
    prop :user_id, String, name: "userid"
  end

  class CallbackForceSaveAction < T::Struct
    prop :type,    Integer
    prop :user_id, String, name: "userid"
  end

  class CallbackGenericAction < T::Struct; end

  class CallbackHistory < T::Struct
    prop :changes,        T::Hash[T.untyped, T.untyped]
    prop :server_version, String,                       name: "serverVersion"
  end

  Callback = T.type_alias do
    T.any(
      CallbackBusy,
      CallbackReady,
      CallbackSaveError,
      CallbackOmitted,
      CallbackSaved,
      CallbackForceSaveError
    )
  end

  class CallbackBusy < T::Struct
    prop :actions,   T.nilable(T::Array[CallbackGenericAction])
    prop :file_type, T.nilable(String),                         name: "filetype"
    prop :key,       String
    prop :user_data, T.nilable(String),                         name: "userdata"
    prop :status,    Integer
  end

  class CallbackReady < T::Struct
    prop :actions,     T.nilable(T::Array[CallbackGenericAction])
    prop :changes_url, String,                                    name: "changesurl"
    prop :file_type,   T.nilable(String),                         name: "filetype"
    prop :history,     CallbackHistory
    prop :key,         String
    prop :status,      Integer
    prop :url,         String
    prop :user_data,   T.nilable(String),                         name: "userdata"
    prop :users,       T::Array[String]
  end

  class CallbackSaveError < T::Struct
    prop :actions,     T.nilable(T::Array[CallbackGenericAction])
    prop :changes_url, String,                                    name: "changesurl"
    prop :file_type,   T.nilable(String),                         name: "filetype"
    prop :history,     CallbackHistory
    prop :key,         String
    prop :status,      Integer
    prop :user_data,   T.nilable(String),                         name: "userdata"
    prop :url,         String
  end

  class CallbackOmitted < T::Struct
    prop :actions,   T.nilable(T::Array[CallbackGenericAction])
    prop :file_type, T.nilable(String),                         name: "filetype"
    prop :key,       String
    prop :user_data, T.nilable(String),                         name: "userdata"
    prop :status,    Integer
  end

  class CallbackSaved < T::Struct
    prop :actions,         T.nilable(T::Array[CallbackGenericAction])
    prop :file_type,       T.nilable(String),                         name: "filetype"
    prop :force_save_type, Integer,                                   name: "forcesavetype"
    prop :key,             String
    prop :status,          Integer
    prop :user_data,       T.nilable(String),                         name: "userdata"
    prop :url,             String
  end

  class CallbackForceSaveError < T::Struct
    prop :actions,         T.nilable(T::Array[CallbackGenericAction])
    prop :file_type,       T.nilable(String),                         name: "filetype"
    prop :force_save_type, Integer,                                   name: "forcesavetype"
    prop :key,             String
    prop :status,          Integer
    prop :url,             String
    prop :user_data,       T.nilable(String),                         name: "userdata"
    prop :users,           T::Array[String]
  end

  class CallbackError < T::Struct
    prop :error,   Integer, default: 0
    prop :message, String,  default: ""
  end

  class CallbackDisconnectAction
    extend T::Sig

    sig { returns(String) }
    def description
      "User disconnects from the document co-editing"
    end
  end

  class CallbackConnectAction
    extend T::Sig

    sig { returns(String) }
    def description
      "New user connects to the document co-editing"
    end
  end

  class CallbackForceSaveAction
    extend T::Sig

    sig { returns(String) }
    def description
      "User clicks the forcesave button"
    end
  end

  class CallbackGenericAction
    extend T::Sig

    sig { params(hash: T.untyped, strict: T.untyped).returns(CallbackAction) }
    def self.from_hash(hash, strict = nil)
      unless hash && hash.is_a?(Hash)
        raise ArgumentError, "#{hash.inspect} provided to from_hash"
      end

      type = hash["type"]
      case type
      when 0
        CallbackDisconnectAction.from_hash(hash, strict)
      when 1
        CallbackConnectAction.from_hash(hash, strict)
      when 2
        CallbackForceSaveAction.from_hash(hash, strict)
      else
        raise ArgumentError, "unknown action type (#{type})"
      end
    end
  end

  class CallbackGeneric < T::Struct
    extend T::Sig

    sig { params(hash: T.untyped, strict: T.untyped).returns(Callback) }
    def self.from_hash(hash, strict = nil)
      unless hash && hash.is_a?(Hash)
        raise ArgumentError, "#{hash.inspect} provided to from_hash"
      end

      status = hash["status"]
      case status
      when 1
        CallbackBusy.from_hash(hash, strict)
      when 2
        CallbackReady.from_hash(hash, strict)
      when 3
        CallbackSaveError.from_hash(hash, strict)
      when 4
        CallbackOmitted.from_hash(hash, strict)
      when 6
        CallbackSaved.from_hash(hash, strict)
      when 7
        CallbackForceSaveError.from_hash(hash, strict)
      else
        raise ArgumentError, "unknown status (#{status})"
      end
    end
  end

  class CallbackBusy
    extend T::Sig

    sig { returns(String) }
    def description
      "Document is being edited"
    end
  end

  class CallbackReady
    extend T::Sig

    sig { returns(String) }
    def description
      "Document is ready for saving"
    end
  end

  class CallbackSaveError
    extend T::Sig

    sig { returns(String) }
    def description
      "Document saving error has occurred"
    end
  end

  class CallbackOmitted
    extend T::Sig

    sig { returns(String) }
    def description
      "Document is closed with no changes"
    end
  end

  class CallbackSaved
    extend T::Sig

    sig { returns(String) }
    def description
      "Document is being edited, but the current document state is saved"
    end
  end

  class CallbackForceSaveError
    extend T::Sig

    sig { returns(String) }
    def description
      "Error has occurred while force saving the document"
    end
  end

  class CallbackError
    class << self
      extend T::Sig

      sig { returns(CallbackError) }
      attr_reader :no_error
    end

    @no_error = T.let(new(error: 0), CallbackError)
  end
end
