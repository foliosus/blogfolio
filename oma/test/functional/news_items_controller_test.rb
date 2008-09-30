require 'test_helper'

class NewsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:news_item)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_news
    assert_difference('NewsItem.count') do
      post :create, :news_item => { }
    end

    assert_redirected_to news_item_path(assigns(:news_item))
  end

  def test_should_show_news
    get :show, :id => news_items(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => news_items(:one).id
    assert_response :success
  end

  def test_should_update_news
    put :update, :id => news_items(:one).id, :news_item => { }
    assert_redirected_to news_item_path(assigns(:news_item))
  end

  def test_should_destroy_news
    assert_difference('NewsItem.count', -1) do
      delete :destroy, :id => news_items(:one).id
    end

    assert_redirected_to news_items_path
  end
end
