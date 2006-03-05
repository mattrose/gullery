require File.dirname(__FILE__) + '/../test_helper'
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < Test::Unit::TestCase

  def setup
    @controller = ProjectsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # TODO
  # test_sort
  # require login for sort

  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  def test_create_restricted
    assert_requires_login { post :create }
    assert_accepts_login(:quentin) { post :create, :project => { :name => 'Fox Tall Action Figure' } }
  end
  
  def test_update_restricted
    assert_requires_login { post :update }
    assert_accepts_login(:quentin) { post :update, :id => 1, :name => 'Cloneberry Lollipop' }
  end
  
  def test_destroy_restricted
    assert_requires_login { get :destroy }
    assert_accepts_login(:quentin) { get :destroy, :id => 1 }
  end

  def test_show
    get :show, :id => 1
    assert_response :success
    assert_not_nil assigns(:project)
    assert_equal 3, assigns(:project).visible_assets.length
  end
  
  def test_create
    old_count = Project.count
    login_as :quentin
    post :create, :project => { :name => 'Fox Tall Action Figure' }
    assert_response :success
    assert_not_nil assigns(:project)
    assert_equal 'text/javascript', @response.headers['Content-Type']
    
    assert_equal old_count + 1, Project.count
  end
  
  def test_update
    old_count = Project.count
    login_as :quentin
    post :update, :id => 1, :project => { :name => 'Fox Small Beanie' }
    assert_response :success
    assert_not_nil assigns(:project)
    assert_equal 'text/javascript', @response.headers['Content-Type']
    
    assert_equal 1, @controller.current_user.projects.length
    project = Project.find 1
    assert_equal 'Fox Small Beanie', project.name
    assert_equal old_count, Project.count
  end
  
  def test_destroy
    old_count = Project.count
    login_as :quentin
    post :destroy, :id => 1
    assert_response :success
    assert_not_nil assigns(:project)
    
    assert_equal old_count - 1, Project.count
  end

  def test_bad_create
    old_count = Project.count
    login_as :quentin
    post :create, :project => { }
    assert_response :success
    assert_not_nil assigns(:project).errors.on(:name)
    
    assert_equal old_count, Project.count
  end

  def test_bad_update
    old_count = Project.count
    login_as :quentin
    post :update
    assert_nil assigns(:project)
    assert_equal old_count, Project.count
  end
  
end
