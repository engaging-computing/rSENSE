require 'test_helper'

class NewsControllerTest < ActionController::TestCase
  setup do
    @nixon = users(:nixon)
    @news = news(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:news)
  end

  test "should create news" do
    assert_difference('News.count') do
      post :create, { news: { title: "Breaking News!" }}, { user_id: @nixon }
    end

    assert_redirected_to news_path(assigns(:news))
  end

  test "should show news" do
    get :show, id: @news
    assert_response :success
  end

  test "should update news" do
    put :update, { id: @news, news: { title: "It's raining" } }, { user_id: @nixon }
    assert_redirected_to news_path(assigns(:news))
  end

  test "should destroy news" do
    assert_difference('News.count', -1) do
      delete :destroy, { id: @news }, { user_id: @nixon }
    end

    assert_redirected_to news_index_path
  end
end
