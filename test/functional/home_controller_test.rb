require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should get about' do
    get :about
    assert_response :success
  end

  test 'should get contact' do
    get :contact
    assert_response :success
  end

  test 'should get privacy policy' do
    get :privacy_policy
    assert_response :success
  end

  test 'should get api page' do
    get :api_v1
    assert_response :success
  end
end
