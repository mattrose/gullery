class ProjectsController < ApplicationController
  
  before_filter :login_required, :only => [:create, :update, :destroy, :sort]
  
  def index
    @projects = Project.find :all, :order => 'position, created_at'
  end

  def show
    @project = Project.find @params[:id]
  end

  def create
    @project = Project.new @params[:project]
    @project.user_id = current_user.id
    unless @project.save
      render :action => 'error'
    end
  end
  
  def update
    
  end
  
  def destroy
    @project = Project.find @params[:id]
    @project.destroy
  end

  def sort
    
    render :nothing => true
  end
  
end
