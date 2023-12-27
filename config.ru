# typed: false
# frozen_string_literal: true

require_relative "config/environment"

# Allow Redmine appears as if it's in a subdirectory.
# https://github.com/docker-library/redmine/pull/99
map ENV["RAILS_RELATIVE_URL_ROOT"] || "/" do
  run Rails.application
end
