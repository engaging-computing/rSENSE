require 'test_helper'
require_relative 'base_integration_test'

class SubscriberEmailTest < IntegrationTest
  self.use_transactional_fixtures = false

  # testing subscriber_emails#index
  test 'show all subscriber emails' do
    login('nixon@whitehouse.gov', '12345')
    @email = subscriber_emails(:template)
    visit '/subscriber_emails'

    # test the email search, no email should show up
    fill_in 'start_date', with: '2016-07-07'
    fill_in 'end_date', with: '2017-07-07'
    click_on 'Search'
    assert !page.has_content?(@email.subject), 'Subject showed up when wasn\'t supposed to'
    assert !page.has_content?(@email.created_at), 'Created_at showed up when wasn\'t supposed to'

    # test the email search, 1 email should show up
    fill_in 'start_date', with: '2016-07-07'
    fill_in 'end_date', with: '2018-04-21'
    click_on 'Search'
    assert page.has_content?('1 Email')
    assert page.has_content?(@email.subject), 'Subject did not show up in /subscriber_emails'
    assert page.has_content?(@email.created_at), 'Created_at did not show up in /subscriber_emails'

  end

  # testing subscriber_emails#show
  test 'view specific email' do
    login('nixon@whitehouse.gov', '12345')
    @email = subscriber_emails(:template)
    visit subscriber_email_path(@email)

    # make sure that subscriber_emails/1 has the subject, message, and date created
    assert page.has_content?(@email.subject), 'Subject did not show up in /subscriber_emails/:id'
    assert page.has_content?(@email.message), 'Message did not show up in /subscriber_emails/:id'
    assert page.has_content?(@email.created_at), 'Created_at did not show up in /subscriber_emails/:id'
  end
end

