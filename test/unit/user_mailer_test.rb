require 'test_helper'
 
class UserMailerTest < ActionMailer::TestCase
  # Welcome to the mailing list
  test "welcome" do
    email = UserMailer.send_welcome_to(users(:doug))
    assert_equal ['isenseproject@gmail.com'], email.from
    assert_equal ['dsalvati@cs.uml.edu'], email.to
    assert_equal 'Welcome to the iSENSE mailing list!', email.subject
    assert_equal read_fixture('welcome.html').join, email.body.to_s.gsub(/users\/.*\/unsubscribe\?token=.*\"/, 'users/foo/unsubscribe?token=bar"')
  end
  
  # Custom email sent out to user group
  test "subscribers" do
    message = SubscriberEmail.new
    message.subject = "What about the droid attack on the Wookiees?"
    message.message = "It's a system we can't afford to lose."
    email = UserMailer.send_subscriber_email(users(:doug), message)
    assert_equal ['isenseproject@gmail.com'], email.from
    assert_equal ['dsalvati@cs.uml.edu'], email.to
    assert_equal 'What about the droid attack on the Wookiees?', email.subject
    assert_equal read_fixture('subscribers.html').join, email.body.to_s.gsub(/users\/.*\/unsubscribe\?token=.*\"/, 'users/foo/unsubscribe?token=bar"')
  end
end