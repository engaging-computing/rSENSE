ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'simplecov'
require 'simplecov_rsense'
SimpleCov.start 'rsense'

require 'capybara/rails'
Capybara.javascript_driver = :none

require 'minitest/reporters'
require 'seed_reporter'

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new, Minitest::Reporters::SpecReporter.new, Minitest::Reporters::SeedReporter.new]

require 'selenium-webdriver'

require 'capybara-screenshot/minitest'
Capybara::Screenshot.autosave_on_failure = false

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Method tests if a given field is nil
  def assert_default_nil(model, field)
    assert_nil(field, " Expected #{model.class} #{field} is not nil.")
  end

  # Method tests if a given field is equal to false
  def assert_default_false(model, field)
    assert_equal false, field, "Expected #{model.class} #{field} does not have the correct default field."
  end

  # Method tests if a given field is equal to false
  def assert_default_true(model, field)
    assert_equal true, field, "Expected #{model.class} #{field} does not have the correct default field."
  end

  def assert_contains(short, long)
    assert_not_nil long.to_s.index(short.to_s),
      "String does not contain #{short}"
  end

  def assert_not_contains(short, long)
    assert_nil long.to_s.index(short.to_s),
      "String contains #{short}"
  end

  def assert_valid_html(text)
    temp = Tempfile.new(['foo', '.html'])
    begin
      temp.write(text)
      temp.close

      script = Rails.root.join('test', 'html5check.py')
      result = `(python "#{script}" --encoding=utf-8 "#{temp.path}") 2>&1`
      status = result.split(/\r?\n/)[0]

      test = (status == '200' && result =~ /^The document is valid HTML5/)
      assert test || status == '503', "HTML invalid:\n#{result}"
    ensure
      temp.unlink
    end
    true
  end
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
end

module CapyHelper
  def login(email, pass)
    visit '/'
    find(:css, '.navbar').click_on('Login')
    fill_in 'Email', with: email
    fill_in 'Password', with: pass
    find(:css, '.mainContent').click_on('Login')

    assert page.has_content?('Logout'), 'Successfully logged in.'
  end

  def logout
    visit '/'
    find(:css, '.navbar').click_on('Logout')
  end

  def finish
    begin
      logout
    rescue Capybara::ElementNotFound
      # don't care
    end

    begin
      Capybara.reset_sessions!
    rescue Exception
      # don't care
    end
  end

  def wait_for_css(selector)
    unless page.has_css?("#{selector}")
      fail Exception.new("No such selector #{selector}")
    end
  end

  def wait_for_id(id)
    wait_for_css("##{id}")
    # wait = Selenium::WebDriver::Wait.new(timeout: 20)
    # wait.until { page.driver.browser.find_element(id: id).displayed? }
  end

  def wait_for_class(cl)
    wait_for_css(".#{cl}")
    # wait = Selenium::WebDriver::Wait.new(timeout: 20)
    # wait.until { page.driver.browser.find_element(class: cl).displayed? }
  end

  def fill_in_content(text)
    page.execute_script <<-SCRIPT
      $('#content-area').code("#{text}");
    SCRIPT
  end
end

def assert_similar_arrays(a, b)
  c = a - b
  d = b - a
  assert c.length + d.length == 0, "Arrays\n\n#{a}\n\nand\n\n#{b}\n\ndo not have the same contents: #{c + d}"
end
