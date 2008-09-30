require 'test_helper'

class ClassifiedsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:classifieds)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_classified
    assert_difference('Classified.count') do
      post :create, :classified => { }
    end

    assert_redirected_to classified_path(assigns(:classified))
  end

  def test_should_show_classified
    get :show, :id => classifieds(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => classifieds(:one).id
    assert_response :success
  end

  def test_should_update_classified
    put :update, :id => classifieds(:one).id, :classified => { }
    assert_redirected_to classified_path(assigns(:classified))
  end

  def test_should_destroy_classified
    assert_difference('Classified.count', -1) do
      delete :destroy, :id => classifieds(:one).id
    end

    assert_redirected_to classifieds_path
  end
end
