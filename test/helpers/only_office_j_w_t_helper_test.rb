# typed: false
# frozen_string_literal: true

require "logger"
require "json"
require "stringio"
require "tempfile"
require "net/http"
require "minitest/autorun"
require "action_controller"
require "jwt"
require_relative "../../lib2/onlyoffice/config"
require_relative "../../lib2/only_office/config"
require_relative "../../lib/only_office_redmine/error"
require_relative "../../app/helpers/only_office_j_w_t_helper"

# Keep these helper tests runnable without booting a Redmine installation.
unless defined?(ApplicationController)
  class ApplicationController < ActionController::Base
  end
end

class OnlyOfficeJWTHelperTest < Minitest::Test
  class RackInput
    def initialize(body)
      @stream = StringIO.new(body)
    end

    def read(*args)
      @stream.read(*args)
    end

    def rewind
      @stream.rewind
    end
  end

  class Controller < ApplicationController
    include OnlyOfficeJWTHelper
  end

  def setup
    @jwt = OnlyOffice::Config::JWT.new(secret: "test-only-secret")
    @payload = {"key" => "test-document", "status" => 1}
    @body = @jwt.encode_payload(@payload)
  end

  def test_post_accepts_rack_stream_that_is_not_an_io
    controller = controller_for(RackInput.new(@body))
    controller.send(:verify_general_jwt_token, @jwt)

    assert_equal @payload, JSON.parse(controller.request.body.read)
    assert_equal @payload.to_json.bytesize, controller.request.get_header("CONTENT_LENGTH")
    refute controller.request.has_header?("RAW_POST_DATA")
  end

  def test_post_rewinds_previously_read_stream
    input = RackInput.new(@body)
    input.read(5)
    controller = controller_for(input)
    controller.send(:verify_general_jwt_token, @jwt)

    assert_equal @payload, JSON.parse(controller.request.body.read)
  end

  def test_post_keeps_string_io_support
    controller = controller_for(StringIO.new(@body))
    controller.send(:verify_general_jwt_token, @jwt)

    assert_equal @payload, JSON.parse(controller.request.body.read)
  end

  def test_post_keeps_file_io_support
    Tempfile.create("onlyoffice-callback-test") do |file|
      file.write(@body)
      file.rewind
      controller = controller_for(file)
      controller.send(:verify_general_jwt_token, @jwt)

      assert_equal @payload, JSON.parse(controller.request.body.read)
    end
  end

  def test_post_uses_signed_payload_instead_of_unsigned_body_fields
    body = JSON.parse(@body).merge("status" => 2).to_json
    controller = controller_for(RackInput.new(body))
    controller.send(:verify_general_jwt_token, @jwt)

    assert_equal @payload, JSON.parse(controller.request.body.read)
  end

  def test_post_rejects_invalid_signature
    body = OnlyOffice::Config::JWT.new(secret: "wrong-test-secret").encode_payload(@payload)
    controller = controller_for(RackInput.new(body))

    error = assert_raises(OnlyOfficeRedmine::Error) do
      controller.send(:verify_general_jwt_token, @jwt)
    end
    assert_same OnlyOfficeRedmine::Error.unauthorized, error
  end

  def test_post_rejects_missing_token
    controller = controller_for(RackInput.new(@payload.to_json))

    assert_raises(OnlyOfficeRedmine::Error) do
      controller.send(:verify_general_jwt_token, @jwt)
    end
  end

  private

  def controller_for(input)
    env = Rack::MockRequest.env_for("/onlyoffice/attachments/1/callback", method: "POST", input: @body)
    env["rack.input"] = input
    controller = Controller.new
    controller.request = ActionDispatch::Request.new(env)
    controller
  end
end
