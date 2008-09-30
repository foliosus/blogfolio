require 'test_helper'

class MemberUpdatesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:member_updates)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_member_update
    assert_difference('MemberUpdate.count') do
      post :create, :member_update => { }
    end

    assert_redirected_to member_update_path(assigns(:member_update))
  end

  def test_should_show_member_update
    get :show, :id => member_updates(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => member_updates(:one).id
    assert_response :success
  end

  def test_should_update_member_update
    put :update, :id => member_updates(:one).id, :member_update => { }
    assert_redirected_to member_update_path(assigns(:member_update))
  end

  def test_should_destroy_member_update
    assert_difference('MemberUpdate.count', -1) do
      delete :destroy, :id => member_updates(:one).id
    end

    assert_redirected_to member_updates_path
  end
end
