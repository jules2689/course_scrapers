$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'einstein'

require 'minitest/autorun'
require 'minitest/unit'
require 'mocha/mini_test'

ENV["ruby_env"] = "test"
