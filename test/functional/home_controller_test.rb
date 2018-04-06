require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test 'should get index' do
    get :index
    assert_response :success
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'should get about' do
    get :about
    assert_response :success
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'should get contact' do
    get :contact
    assert_response :success
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'should get privacy policy' do
    get :privacy_policy
    assert_response :success
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'should get api page' do
    get :api_v1
    assert_response :success
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'should get bug report page' do
    get :report_bug
    assert_response :success
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'report inappropriate content should send email' do
    params = { prev_url: 'https://www.uml.edu', current_user: '1234', content: 'foo' }
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post :report_content_submit, params
    end
    email = ActionMailer::Base.deliveries.last
    assert_equal 'Report of inappropriate content on iSENSE.', email.subject
    assert_equal 'isenseproject@gmail.com', email.to[0]
  end
end
