require 'test_helper'

class MediaObjectsControllerTest < ActionController::TestCase
  setup do
    @nixon = users(:nixon)
    @media_object = media_objects(:one)
  end

  test "should show media_object" do
    get :show, { id: @media_object }, { user_id: @nixon }
    assert_response :success
  end

  test "should update media_object" do
    put :update, { id: @media_object, media_object: { project_id: @media_object.project_id, 
      media_type: @media_object.media_type, name: @media_object.name, data_set_id: @media_object.data_set_id,
      user_id: @media_object.user_id }}, { user_id: @nixon }
    assert_redirected_to media_object_path(assigns(:media_object))
  end

  test "should destroy media_object" do
    assert_difference('MediaObject.count', -1) do
      delete :destroy, { id: @media_object }, { user_id: @nixon }
    end

    assert_redirected_to media_objects_path
  end

  # No test for saveMedia
  # Uploading to amazon in tests seems hard.
end
