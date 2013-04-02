ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  # Method tests if a given field is nil
  def assert_default_nil(model, field)
    assert_nil( field, " Expected #{model.class} #{field} is not nil." )
  end
  
  # Method tests if a given field is equal to false
  def assert_default_false(model, field)
    assert_equal false, field, "Expected #{model.class} #{field} does not have the correct default field."
  end
  
end
