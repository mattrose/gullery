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

  def test_restricted_create
    assert_requires_login(:quentin) { post :create }
    # TODO assert_accepts_login(:quentin) { post :create, :name => 'Fox Tall Action Figure' }
  end

  def test_restricted_update
    assert_requires_login(:quentin) { post :update }
    assert_accepts_login(:quentin) { post :update, :id => 1, :caption => 'The can...even closer' }
  end

  def test_restricted_destroy
    assert_requires_login(:quentin) { get :destroy, :id => 1 }
    assert_accepts_login(:quentin) { get :destroy, :id => 1 }    
  end

  def test_restricted_sort
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
    assert_equal 'text/javascript', @response.headers['Content-Type']
  end
  
  def test_update
    login_as :quentin
    post :update, :id => 1, :asset => { :caption => 'Alternate logo on can' }
    assert_response :success
    assert_not_nil assigns(:asset)
    assert assigns(:asset).valid?
    assert_equal 'text/javascript', @response.headers['Content-Type']
    
    assert_equal 'Alternate logo on can', Asset.find(1).caption
  end

  def test_destroy
    login_as :quentin
    asset = Asset.find(1)
    project = asset.project
    old_count = project.assets.length
    post :destroy, :id => 1
    assert_response :success
    assert_equal 'text/javascript', @response.headers['Content-Type']
    
    assert_equal old_count - 1, project.assets.count
  end
  
  def test_rotate
    login_as :quentin
    post :rotate, :id => 1, :direction => 'cw'
    # TODO Look at actual file
    assert_redirected_to projects_url(:action => 'show', :id => 1)
  end

end
