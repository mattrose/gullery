# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def show_page_title
    @page_title || 'gullery photo gallery'
  end

  def show_page_nav
    user = User.find_first
    nav = link_to((user.company || user.name || 'gullery'), :controller => '/')
    nav += ' ' + content_tag(:small, link_to((@project.name), projects_url(:action => 'show', :id => @project))) if @project
    nav
  end
  
  
end
