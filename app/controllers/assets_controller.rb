class AssetsController < ApplicationController

  def create
    @asset = Asset.new @params[:asset]
    if @asset.save
      redirect_to projects_url(:action => 'show', :id => @asset.project_id)
    else
      render :inline => "<%= error_messages_for :asset %>"
    end
  end

end
