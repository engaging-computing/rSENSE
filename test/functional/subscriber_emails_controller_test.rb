require 'test_helper'

class SubscriberEmailsControllerTest < ActionController::TestCase
  test 'send email to subscribers' do
    nixon = sign_in('user', users(:nixon))
    # Trigger an email to be sent and make sure it got queued up
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post :create, { subscriber_email: { subject: 'ECG', message: 'asdfasd' } },  user_id: nixon
    end
    # Check out the email and make sure it has proper values
    invite_email = ActionMailer::Base.deliveries.last
    assert_equal invite_email.subject, 'ECG'
    assert_equal 'pson@cs.uml.edu', invite_email.to[0]
  end
end