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

module OnlyOffice::Format; end

class OnlyOffice::Format::Format < T::Struct
  extend T::Sig

  const :name, String
  const :type, String
  const :actions, T::Array[String]
  const :convert, T::Array[String]
  const :mime, T::Array[String]

  sig do
    params(
      hash: T.untyped,
      strict: T.untyped
    )
      .returns(OnlyOffice::Format::Format)
  end
  def self.from_hash(hash, strict = nil)
    super(hash, strict)
  end

  sig { returns(String) }
  def extension
    ".#{name}"
  end

  sig { returns(T::Boolean) }
  def fillable?
    actions.include?("fill")
  end

  sig { returns(T::Boolean) }
  def viewable?
    actions.include?("view")
  end

  sig { returns(T::Boolean) }
  def editable?
    actions.include?("edit")
  end

  sig { returns(T::Boolean) }
  def lossy_editable?
    actions.include?("lossy-edit")
  end

  sig { returns(T::Boolean) }
  def convertible?
    !convert.empty?
  end

  # TODO: replace the hardcoded logic.
  # We need to wait for the auto convertibale formats to be included in the
  # submodule.
  sig { returns(T::Boolean) }
  def auto_convertible?
    (document? && convert.include?("docx")) ||
      (presentation? && convert.include?("pptx")) ||
      (spreadsheet? && convert.include?("xlsx"))
  end

  # TODO: replace hardcoded format names.
  # We need to wait for the creatable formats to be included in the submodule.
  sig { returns(T::Boolean) }
  def creatable?
    docx? ||
      name == "docxf" ||
      name == "pptx" ||
      name == "xlsx"
  end

  sig { returns(T::Boolean) }
  def spreadsheet?
    type == "cell"
  end

  sig { returns(T::Boolean) }
  def presentation?
    type == "slide"
  end

  sig { returns(T::Boolean) }
  def document?
    type == "word"
  end

  def docx?
    name == "docx"
  end
end

module OnlyOffice::Format::Managering
  extend T::Sig
  extend T::Helpers
  interface!

  sig { abstract.returns(T::Array[OnlyOffice::Format::Format]) }
  def fillable; end

  sig { abstract.returns(T::Array[OnlyOffice::Format::Format]) }
  def viewable; end

  sig { abstract.returns(T::Array[OnlyOffice::Format::Format]) }
  def editable; end

  sig { abstract.returns(T::Array[OnlyOffice::Format::Format]) }
  def lossy_editable; end

  sig { abstract.returns(T::Array[OnlyOffice::Format::Format]) }
  def convertible; end

  sig { abstract.returns(T::Array[OnlyOffice::Format::Format]) }
  def auto_convertible; end

  sig { abstract.returns(T::Array[OnlyOffice::Format::Format]) }
  def creatable; end

  sig { abstract.returns(T::Array[OnlyOffice::Format::Format]) }
  def spreadsheets; end

  sig { abstract.returns(T::Array[OnlyOffice::Format::Format]) }
  def presentations; end

  sig { abstract.returns(T::Array[OnlyOffice::Format::Format]) }
  def documents; end

  sig { abstract.returns(T::Array[OnlyOffice::Format::Format]) }
  def supported; end

  sig { abstract.returns(OnlyOffice::Format::Format) }
  def default; end

  sig { abstract.params(extension: String).returns(T.nilable(OnlyOffice::Format::Format)) }
  def define(extension); end
end

class OnlyOffice::Format::Manager
  extend T::Sig
  include OnlyOffice::Format::Managering

  sig { returns(OnlyOffice::Resource::Managering) }
  attr_reader :resource_manager

  sig { params(resource_manager: OnlyOffice::Resource::Managering).void }
  def initialize(resource_manager:)
    @resource_manager = resource_manager
  end

  # Fillable

  sig { override.returns(T::Array[OnlyOffice::Format::Format]) }
  def fillable
    predefined.filter(&:fillable?)
  end

  # Viewable

  sig { override.returns(T::Array[OnlyOffice::Format::Format]) }
  def viewable
    predefined.filter(&:viewable?)
  end

  # Editable

  sig { override.returns(T::Array[OnlyOffice::Format::Format]) }
  def editable
    predefined.filter(&:editable?)
  end

  # Lossy Editable

  sig { override.returns(T::Array[OnlyOffice::Format::Format]) }
  def lossy_editable
    predefined.filter(&:lossy_editable?)
  end

  # Convertible

  sig { override.returns(T::Array[OnlyOffice::Format::Format]) }
  def convertible
    predefined.filter(&:convertible?)
  end

  sig { override.returns(T::Array[OnlyOffice::Format::Format]) }
  def auto_convertible
    predefined.filter(&:auto_convertible?)
  end

  # Creatable

  sig { override.returns(T::Array[OnlyOffice::Format::Format]) }
  def creatable
    predefined.filter(&:creatable?)
  end

  # Spreadsheet

  sig { override.returns(T::Array[OnlyOffice::Format::Format]) }
  def spreadsheets
    predefined.filter(&:spreadsheet?)
  end

  # Presentation

  sig { override.returns(T::Array[OnlyOffice::Format::Format]) }
  def presentations
    predefined.filter(&:presentation?)
  end

  # Document

  sig { override.returns(T::Array[OnlyOffice::Format::Format]) }
  def documents
    predefined.filter(&:document?)
  end

  # Supported

  sig { override.returns(T::Array[OnlyOffice::Format::Format]) }
  def supported
    predefined.to_a
  end

  # Predefined

  sig { override.returns(OnlyOffice::Format::Format) }
  def default
    docx
  end

  sig { returns(OnlyOffice::Format::Format) }
  private def docx
    format = define(".docx")
    # The formats always include docx, as it's commonly used in many places by
    # default.
    T.must(format)
  end

  sig { override.params(extension: String).returns(T.nilable(OnlyOffice::Format::Format)) }
  def define(extension)
    predefined.find do |format|
      format.extension == extension
    end
  end

  sig { returns(T::Set[OnlyOffice::Format::Format]) }
  private def predefined
    return @predefined if defined?(@predefined)
    set = T.let(Set.new, T::Set[OnlyOffice::Format::Format])
    contents = file.read
    list = JSON.parse(contents)
    list.each do |item|
      format = OnlyOffice::Format::Format.from_hash(item)
      set.add(format)
    end
    @predefined ||= set
  end

  # Storage

  sig { returns(Pathname) }
  private def file
    directory.join("onlyoffice-docs-formats.json")
  end

  sig { returns(Pathname) }
  private def directory
    @resource_manager.directory.join("document-formats")
  end
end
