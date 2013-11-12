require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  setup do
    Dir.mkdir("/tmp/html_validation")
  end
 
  teardown do
    FileUtils.rm_rf("/tmp/html_validation")
  end
  
  test "should get index" do
    get :index
    assert_response :success
    
    # HTML validation
    assert_valid_html(request.body, "Index Get")
    
  end

  test "should get about" do
    get :about
    assert_response :success
    
    # HTML validation
    assert_valid_html(request.body, "Get About")
 
  end

  test "should get contact" do
    get :contact
    assert_response :success
    
    # HTML validation
    assert_valid_html(request.body, "Get Contact")
  end
end
