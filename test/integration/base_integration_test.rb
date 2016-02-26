require 'test_helper'

class IntegrationTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 2
  end

  teardown do
    finish
  end
end
