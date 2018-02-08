require 'test_helper'
require_relative 'base_integration_test'

class MailingListSubscription < IntegrationTest
  self.use_transactional_fixtures = false

  test 'subscribe and unsubscribe' do
    login('kcarcia@cs.uml.edu', '12345')
    assert !page.has_content?('Welcome Back :)'), 'Pop-up appeared for user who already set preference'
    first('.variable-username').click
    assert page.has_content?('Not Subscribed'), 'User should not be subscribed, but profile indicated she was'
    click_on 'Subscribe'
    assert !page.has_content?('Not Subscribed'), 'User should be subscribed, but profile indicated she was not'
  end

  test 'subscription not set' do
    login('dsalvati@cs.uml.edu', 'password')
    assert page.has_content?('Welcome Back :)'), 'Pop-up did not appear for user with no preference'
    click_on 'Sure'
    first('.variable-username').click
    assert !page.has_content?('Not Subscribed'), 'User should be subscribed, but profile indicated he was not'
  end
end