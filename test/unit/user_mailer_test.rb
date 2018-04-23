require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  # Welcome to the mailing list
  test 'welcome' do
    email = UserMailer.send_welcome_to(users(:doug))
    assert_equal ['isenseproject@gmail.com'], email.from
    assert_equal ['dsalvati@cs.uml.edu'], email.to
    assert_equal 'Welcome to the iSENSE mailing list!', email.subject
    assert_equal read_fixture('welcome.html').join, email.body.to_s.gsub(%r{users/.*/unsubscribe\?token=.*\"}, 'users/foo/unsubscribe?token=bar"')
  end

  # Custom email sent out to user group
  test 'subscribers' do
    message = SubscriberEmail.new
    message.subject = 'What about the droid attack on the Wookiees?'
    message.message = 'It\'s a system we can\'t afford to lose.'
    email = UserMailer.send_subscriber_email(users(:doug), message)
    assert_equal ['isenseproject@gmail.com'], email.from
    assert_equal ['dsalvati@cs.uml.edu'], email.to
    assert_equal 'What about the droid attack on the Wookiees?', email.subject
    assert_equal read_fixture('subscribers.html').join, email.body.to_s.gsub(%r{users/.*/unsubscribe\?token=.*\"}, 'users/foo/unsubscribe?token=bar"')
  end

  # Report inappropriate content
  test 'report content' do
    params = { prev_url: 'https://www.uml.edu', current_user: '1234', content: 'No wise fish would go anywhere without a porpoise.' }
    email = UserMailer.report_content_email(params)
    assert_equal ['isenseproject@gmail.com'], email.from
    assert_equal ['isenseproject@gmail.com'], email.to
    assert_equal 'Report of inappropriate content on iSENSE.', email.subject
    assert_equal read_fixture('report_content_email.html').join, email.body.to_s
  end
end