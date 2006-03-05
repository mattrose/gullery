require File.dirname(__FILE__) + '/../test_helper'
require 'assets_controller'

# Re-raise errors caught by the controller.
class AssetsController; def rescue_action(e) raise e end; end

class AssetsControllerTest < Test::Unit::TestCase
  def setup
    @controller = AssetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_restricted_pages
    assert_requires_login(:quentin) { post :create }
    # TODO assert_accepts_login(:quentin) { post :create, :name => 'Fox Tall Action Figure' }

    assert_requires_login(:quentin) { post :update }
    assert_accepts_login(:quentin) { post :update, :id => 1, :caption => 'The can...even closer' }

    assert_requires_login(:quentin) { get :destroy }
    assert_accepts_login(:quentin) { get :destroy, :id => 1 }

    assert_requires_login(:quentin) { post :sort }
    assert_accepts_login(:quentin) { post :sort, :asset_list => [3, 2, 1] }
  end
  
  def test_create
    login_as :quentin
    # TODO send file for upload
    post :create, :asset => { :project_id => 1, :caption => 'Cloneberry logo' }
    assert_response :success
    assert_not_nil assigns(:asset)
    assert assigns(:asset).valid?
    assert_equal 'text/javascript', @response.headers['Content-type']
  end
  
  def test_update
    post :update, :id => 1, :asset => { :caption => 'Alternate logo on can' }
    assert_response :success
    assert_not_nil assigns(:asset)
    assert assigns(:asset).valid?
    assert_equal 'text/javascript', @response.headers['Content-type']
    
    assert_equal 'Alternate logo on can', Asset.find(1).caption
  end

  def test_destroy
    asset = Asset.find(1)
    project = Asset.project
    old_count = project.assets.length
    post :destroy, :id => 1
    assert_response :successs
    assert_equal 'text/javascript', @response.headers['Content-type']
    
    assert_equal old_count - 1, project.assets.count
  end

end
