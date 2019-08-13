require 'test_helper'

class NewsControllerTest < ActionController::TestCase
  setup do
    @news  = news(:one)
    @news_three = news(:news_three)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:news)
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'should get index (json)' do
    get :index,  format: 'json'
    assert_response :success
    assert_not_nil assigns(:news)
  end

  test 'should show news' do
    get :show,  id: @news
    assert_response :success
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'should show news (json)' do
    get :show,  format: 'json', id: @news_three
    assert_response :success

    get :show, format: 'json', id: @news_three, recur: true
    assert JSON.parse(response.body).key?('content'), 'Should have included content in to_hash'
  end

  test 'should create news' do
    nixon = sign_in users(:nixon)
    assert_difference('News.count') do
      post :create, { news: { title: 'News' } },  user_id: nixon
    end

    assert_redirected_to news_path(assigns(:news))
  end

  test 'should create news (json)' do
    nixon = sign_in users(:nixon)
    assert_difference('News.count') do
      post :create, { news: { title: 'News' }, format: 'json' },  user_id: nixon
    end

    assert_response :success
  end

  test 'should not create news as non-admin (json)' do
    kate = sign_in users(:kate)
    assert_difference('News.count', 0) do
      post :create, { format: 'json' },  user_id: kate
    end

    assert_response :forbidden
  end

  test 'should update news' do
    nixon = sign_in users(:nixon)
    put :update, { id: @news, news: { title: "It's raining" } },  user_id: nixon

    news = News.find @news.id
    assert news.title == "It's raining", 'Title did not change correctly.'

    assert_redirected_to news_path(assigns(:news))
  end

  test 'should update news (json)' do
    nixon = sign_in users(:nixon)
    put :update, { format: 'json', id: @news, news: { title: "It's raining" } },  user_id: nixon

    news = News.find @news.id
    assert news.title == "It's raining", 'Title did not change correctly.'

    assert_response :success
  end

  test 'should destroy news' do
    nixon = sign_in users(:nixon)
    assert_difference('News.count', -1) do
      delete :destroy, { id: @news },  user_id: nixon
    end
    assert_redirected_to news_index_path
  end

  test 'should destroy news (json)' do
    nixon = sign_in users(:nixon)
    assert_difference('News.count', -1) do
      delete :destroy, { format: 'json', id: @news },  user_id: nixon
    end
    assert_response :success
  end
end
