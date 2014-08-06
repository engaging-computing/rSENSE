require 'test_helper'

class MediaObjectsControllerTest < ActionController::TestCase
  setup do
    @nixon = users(:nixon)
    @media_object = media_objects(:one)
  end

  test 'should show media_object' do
    get :show, { id: @media_object },  user_id: @nixon
    assert_response :success
  end

  test 'should update media_object' do
    put :update, { id: @media_object, media_object: { project_id: @media_object.project_id,
      media_type: @media_object.media_type, name: @media_object.name, data_set_id: @media_object.data_set_id,
      user_id: @media_object.user_id } },  user_id: @nixon
    assert_redirected_to media_object_path(assigns(:media_object))
  end

  test 'should upload media to user' do
    assert_difference('MediaObject.count') do
      img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
      file = Rack::Test::UploadedFile.new(img_path, 'image/jpeg')
      post :saveMedia, { keys: "user/#{@nixon.id}", upload: file }, user_id: @nixon
    end

    get :show, format: 'json', id: MediaObject.last.id, recur: true
    assert !JSON.parse(response.body)['owner'].nil?, 'Should have included user hash'
  end

  test 'should upload media to visualization' do
    viz_id = visualizations(:media_test).id

    assert_difference('MediaObject.count') do
      img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
      file = Rack::Test::UploadedFile.new(img_path, 'image/jpeg')
      post :saveMedia, { keys: "visualization/#{viz_id}", upload: file }, user_id: @nixon
    end

    get :show, format: 'json', id: MediaObject.last.id, recur: true
    assert !JSON.parse(response.body)['visualization'].nil?, 'Should have included visualization hash'
  end

  test 'should upload media to data_set' do
    dset_id = visualizations(:media_test).id

    assert_difference('MediaObject.count') do
      img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
      file = Rack::Test::UploadedFile.new(img_path, 'image/jpeg')
      post :saveMedia, { keys: "data_set/#{dset_id}", upload: file }, user_id: @nixon
    end

    get :show, format: 'json', id: MediaObject.last.id, recur: true
    assert !JSON.parse(response.body)['dataSet'].nil?, 'Should have included data_set hash'
  end

  test 'should upload media to tutorial' do
    tut_id = tutorials(:media_test).id

    assert_difference('MediaObject.count') do
      img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
      file = Rack::Test::UploadedFile.new(img_path, 'image/jpeg')
      post :saveMedia, { keys: "tutorial/#{tut_id}", upload: file }, user_id: @nixon
    end

    get :show, format: 'json', id: MediaObject.last.id, recur: true
    assert !JSON.parse(response.body)['tutorial'].nil?, 'Should have included tutorial hash'
  end

  test 'should upload media to news' do
    news_id = news(:media_test).id

    assert_difference('MediaObject.count') do
      img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
      file = Rack::Test::UploadedFile.new(img_path, 'image/jpeg')
      post :saveMedia, { keys: "news/#{news_id}", upload: file }, user_id: @nixon
    end

    get :show, format: 'json', id: MediaObject.last.id, recur: true
    assert !JSON.parse(response.body)['news'].nil?, 'Should have included news hash'
  end

  test 'should destroy media_object' do
    assert_difference('MediaObject.count', -1) do
      delete :destroy, { id: @media_object },  user_id: @nixon
    end
    assert_redirected_to @media_object.project
  end

  # No test for saveMedia
  # Uploading to amazon in tests seems hard.
end

class Rack::Test::UploadedFile
  def tempfile
    @tempfile
  end
end
