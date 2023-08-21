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

require_relative "../helper"

class FormatStub
  extend T::Sig

  sig { returns(OnlyOffice::Format::Format) }
  def self.fillable
    contents =
      '
      {
        "name": "",
        "type": "",
        "actions": ["fill"],
        "convert": [],
        "mime": []
      }
      '
    hash = JSON.parse(contents)
    OnlyOffice::Format::Format.from_hash(hash)
  end

  sig { returns(OnlyOffice::Format::Format) }
  def self.viewable
    contents =
      '
      {
        "name": "",
        "type": "",
        "actions": ["view"],
        "convert": [],
        "mime": []
      }
      '
    hash = JSON.parse(contents)
    OnlyOffice::Format::Format.from_hash(hash)
  end

  sig { returns(OnlyOffice::Format::Format) }
  def self.editable
    contents =
      '
      {
        "name": "",
        "type": "",
        "actions": ["edit"],
        "convert": [],
        "mime": []
      }
      '
    hash = JSON.parse(contents)
    OnlyOffice::Format::Format.from_hash(hash)
  end

  sig { returns(OnlyOffice::Format::Format) }
  def self.lossy_editable
    contents =
      '
      {
        "name": "",
        "type": "",
        "actions": ["lossy-edit"],
        "convert": [],
        "mime": []
      }
      '
    hash = JSON.parse(contents)
    OnlyOffice::Format::Format.from_hash(hash)
  end

  sig { returns(OnlyOffice::Format::Format) }
  def self.convertible
    contents =
      '
      {
        "name": "",
        "type": "",
        "actions": [],
        "convert": ["docx"],
        "mime": []
      }
      '
    hash = JSON.parse(contents)
    OnlyOffice::Format::Format.from_hash(hash)
  end

  sig { returns(OnlyOffice::Format::Format) }
  def self.spreadsheet
    contents =
      '
      {
        "name": "",
        "type": "cell",
        "actions": [],
        "convert": [],
        "mime": []
      }
      '
    hash = JSON.parse(contents)
    OnlyOffice::Format::Format.from_hash(hash)
  end

  sig { returns(OnlyOffice::Format::Format) }
  def self.presentation
    contents =
      '
      {
        "name": "",
        "type": "slide",
        "actions": [],
        "convert": [],
        "mime": []
      }
      '
    hash = JSON.parse(contents)
    OnlyOffice::Format::Format.from_hash(hash)
  end

  sig { returns(OnlyOffice::Format::Format) }
  def self.document
    contents =
      '
      {
        "name": "",
        "type": "word",
        "actions": [],
        "convert": [],
        "mime": []
      }
      '
    hash = JSON.parse(contents)
    OnlyOffice::Format::Format.from_hash(hash)
  end

  sig { returns(OnlyOffice::Format::Format) }
  def self.docx
    contents =
      '
      {
        "name": "docx",
        "type": "",
        "actions": [],
        "convert": [],
        "mime": []
      }
      '
    hash = JSON.parse(contents)
    OnlyOffice::Format::Format.from_hash(hash)
  end

  sig { returns(OnlyOffice::Format::Format) }
  def self.unknown
    contents =
      '
      {
        "name": "unknown",
        "type": "",
        "actions": [],
        "convert": [],
        "mime": []
      }
      '
    hash = JSON.parse(contents)
    OnlyOffice::Format::Format.from_hash(hash)
  end
end

class FormatTests < Minitest::Test
  def test_identifies_as_docx
    format = FormatStub.docx
    assert_predicate(format, :docx?)
  end

  def test_not_identifies_as_docx
    format = FormatStub.unknown
    refute_predicate(format, :docx?)
  end

  def test_identifies_as_a_document
    format = FormatStub.document
    assert_predicate(format, :document?)
  end

  def test_not_identifies_as_a_document
    format = FormatStub.unknown
    refute_predicate(format, :document?)
  end

  def test_identifies_as_a_presentation
    format = FormatStub.presentation
    assert_predicate(format, :presentation?)
  end

  def test_not_identifies_as_a_presentation
    format = FormatStub.unknown
    refute_predicate(format, :presentation?)
  end

  def test_identifies_as_a_spreadsheet
    format = FormatStub.spreadsheet
    assert_predicate(format, :spreadsheet?)
  end

  def test_not_identifies_as_a_spreadsheet
    format = FormatStub.unknown
    refute_predicate(format, :spreadsheet?)
  end

  def test_identifies_as_a_convertible
    format = FormatStub.convertible
    assert_predicate(format, :convertible?)
  end

  def test_not_identifies_as_a_convertible
    format = FormatStub.unknown
    refute_predicate(format, :convertible?)
  end

  def test_identifies_as_a_lossy_editable
    format = FormatStub.lossy_editable
    assert_predicate(format, :lossy_editable?)
  end

  def test_not_identifies_as_a_lossy_editable
    format = FormatStub.unknown
    refute_predicate(format, :lossy_editable?)
  end

  def test_identifies_as_a_editable
    format = FormatStub.editable
    assert_predicate(format, :editable?)
  end

  def test_not_identifies_as_a_editable
    format = FormatStub.unknown
    refute_predicate(format, :editable?)
  end

  def test_identifies_as_a_viewable
    format = FormatStub.viewable
    assert_predicate(format, :viewable?)
  end

  def test_not_identifies_as_a_viewable
    format = FormatStub.unknown
    refute_predicate(format, :viewable?)
  end

  def test_identifies_as_a_fillable
    format = FormatStub.fillable
    assert_predicate(format, :fillable?)
  end

  def test_not_identifies_as_a_fillable
    format = FormatStub.unknown
    refute_predicate(format, :fillable?)
  end

  def test_generates_extension
    format = FormatStub.unknown
    assert_equal(".unknown", format.extension)
  end
end

class FormatManagerPredefinedTests < Minitest::Test
  def test_defines
    resource_manager = OnlyOffice::Resource::Manager.new
    format_manager = OnlyOffice::Format::Manager.new(resource_manager:)
    format = format_manager.define(".docx")
    refute_nil(format)
  end

  def test_not_defines
    resource_manager = OnlyOffice::Resource::Manager.new
    format_manager = OnlyOffice::Format::Manager.new(resource_manager:)
    format = format_manager.define(".unknown")
    assert_nil(format)
  end

  def test_assigns_docx_as_the_default
    resource_manager = OnlyOffice::Resource::Manager.new
    format_manager = OnlyOffice::Format::Manager.new(resource_manager:)
    assert_predicate(format_manager.default, :docx?)
  end
end

class FormatManagerSupportedTests < Minitest::Test
  def test_loads
    resource_manager = OnlyOffice::Resource::Manager.new
    format_manager = OnlyOffice::Format::Manager.new(resource_manager:)
    refute_empty(format_manager.supported)
  end
end

class FormatManagerDocumentTests < Minitest::Test
  def test_loads
    resource_manager = OnlyOffice::Resource::Manager.new
    format_manager = OnlyOffice::Format::Manager.new(resource_manager:)
    refute_empty(format_manager.documents)
    assert(format_manager.documents.all?(&:document?))
  end
end

class FormatManagerPresentationTests < Minitest::Test
  def test_loads
    resource_manager = OnlyOffice::Resource::Manager.new
    format_manager = OnlyOffice::Format::Manager.new(resource_manager:)
    refute_empty(format_manager.presentations)
    assert(format_manager.presentations.all?(&:presentation?))
  end
end

class FormatManagerSpreadsheetTests < Minitest::Test
  def test_loads
    resource_manager = OnlyOffice::Resource::Manager.new
    format_manager = OnlyOffice::Format::Manager.new(resource_manager:)
    refute_empty(format_manager.spreadsheets)
    assert(format_manager.spreadsheets.all?(&:spreadsheet?))
  end
end

class FormatManagerCreatableTests < Minitest::Test
  def test_loads
    resource_manager = OnlyOffice::Resource::Manager.new
    format_manager = OnlyOffice::Format::Manager.new(resource_manager:)
    refute_empty(format_manager.creatable)
    assert(format_manager.creatable.all?(&:creatable?))
  end
end

class FormatManagerAutoConvertibleTests < Minitest::Test
  def test_loads
    resource_manager = OnlyOffice::Resource::Manager.new
    format_manager = OnlyOffice::Format::Manager.new(resource_manager:)
    refute_empty(format_manager.auto_convertible)
    assert(format_manager.auto_convertible.all?(&:auto_convertible?))
  end
end

class FormatManagerConvertibleTests < Minitest::Test
  def test_loads
    resource_manager = OnlyOffice::Resource::Manager.new
    format_manager = OnlyOffice::Format::Manager.new(resource_manager:)
    refute_empty(format_manager.convertible)
    assert(format_manager.convertible.all?(&:convertible?))
  end
end

class FormatManagerLossyEditableTests < Minitest::Test
  def test_loads
    resource_manager = OnlyOffice::Resource::Manager.new
    format_manager = OnlyOffice::Format::Manager.new(resource_manager:)
    refute_empty(format_manager.lossy_editable)
    assert(format_manager.lossy_editable.all?(&:lossy_editable?))
  end
end

class FormatManagerEditableTests < Minitest::Test
  def test_loads
    resource_manager = OnlyOffice::Resource::Manager.new
    format_manager = OnlyOffice::Format::Manager.new(resource_manager:)
    refute_empty(format_manager.editable)
    assert(format_manager.editable.all?(&:editable?))
  end
end

class FormatManagerViewableTests < Minitest::Test
  def test_loads
    resource_manager = OnlyOffice::Resource::Manager.new
    format_manager = OnlyOffice::Format::Manager.new(resource_manager:)
    refute_empty(format_manager.viewable)
    assert(format_manager.viewable.all?(&:viewable?))
  end
end

class FormatManagerFilableTests < Minitest::Test
  def test_loads
    resource_manager = OnlyOffice::Resource::Manager.new
    format_manager = OnlyOffice::Format::Manager.new(resource_manager:)
    refute_empty(format_manager.fillable)
    assert(format_manager.fillable.all?(&:fillable?))
  end
end
