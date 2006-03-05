# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def show_page_title
    @page_title || 'gullery photo gallery'
  end

  def show_page_nav
    link_to "gullery", :controller => '/'
  end
  
end
