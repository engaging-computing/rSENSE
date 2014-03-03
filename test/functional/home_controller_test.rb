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
end
