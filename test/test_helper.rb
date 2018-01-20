# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'einstein'

require 'minitest/autorun'
require 'minitest/unit'
require 'webmock/minitest'
require 'vcr'

class Minitest::Test
  def setup
    VCR.configure do |config|
      config.cassette_library_dir = "test/fixtures/vcr_cassettes"
      config.hook_into :webmock
    end
  end
end
