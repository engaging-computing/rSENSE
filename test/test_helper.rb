ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'capybara/rails'
#Capybara.javascript_driver = :webkit
Capybara.javascript_driver = :selenium

require "selenium-webdriver"

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

  def assert_contains(short, long)
    assert_not_nil long.to_s.index(short.to_s), 
      "String does not contain #{short}"
  end

  def assert_not_contains(short, long)
    assert_nil long.to_s.index(short.to_s),
      "String contains #{short}"
  end
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
end

module CapyHelper
  def login(user, pass)
    visit '/'
    find('.navbar').click_on('Login')
    fill_in 'Username', with: user
    fill_in 'Password', with: pass
    find('.mainContent').click_on('Login')

    assert page.has_content?("Logout")
  end

  def logout
    visit '/'
    find('.navbar').click_on('Logout')
  end

  def finish
    begin
      logout
    rescue Capybara::ElementNotFound
      # don't care
    end

    Capybara.reset_sessions!
  end

  def wait_for_id(id)
    wait = Selenium::WebDriver::Wait.new(:timeout => 20)
    wait.until { page.driver.browser.find_element(:id => id).displayed? }
  end
end
