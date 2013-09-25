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

  test "should get index (json)" do
    get :index, { format: 'json' }
    assert_response :success
    assert_not_nil assigns(:news)
  end

  test "should show news" do
    get :show, { id: @news }
    assert_response :success
  end

  test "should show news (json)" do
    get :show, { format: 'json', id: @news }
    assert_response :success
  end

  test "should create news" do
    assert_difference('News.count') do
      post :create, {}, { user_id: @nixon }
    end

    assert_redirected_to news_path(assigns(:news))
  end

  test "should create news (json)" do
    assert_difference('News.count') do
      post :create, { format: 'json' }, { user_id: @nixon }
    end

    assert_response :success
  end

  test "should update news" do
    put :update, { id: @news, news: { title: "It's raining" } }, { user_id: @nixon }
    
    news = News.find @news.id
    assert news.title == "It's raining", "Title did not change correctly."
    
    assert_redirected_to news_path(assigns(:news))
  end

  test "should update news (json)" do
    put :update, { format: 'json', id: @news, news: { title: "It's raining" } }, { user_id: @nixon }
    
    news = News.find @news.id
    assert news.title == "It's raining", "Title did not change correctly."
    
    assert_response :success
  end

  test "should destroy news" do
    delete :destroy, { id: @news }, { user_id: @nixon }
    
    news = News.find @news.id
    assert_equal news.hidden, true
    assert_equal news.user_id, -1
    assert_equal news.featured_media_id, nil

    assert_redirected_to news_index_path
  end
  
  test "should destroy news (json)" do
    delete :destroy, { format: 'json', id: @news }, { user_id: @nixon }
    
    news = News.find @news.id
    assert_equal news.hidden, true
    assert_equal news.user_id, -1
    assert_equal news.featured_media_id, nil

    assert_response :success
  end
end
