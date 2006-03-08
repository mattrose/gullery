ActionController::Routing::Routes.draw do |map|

  map.connect '', :controller => "projects"

  map.connect 'signup', :controller => "account", :action => 'signup'
  map.connect 'login', :controller => "account", :action => 'login'
  map.connect 'logout', :controller => "account", :action => 'logout'

  map.projects 'projects/:action/:id', :controller => 'projects', :action => 'list'
  map.assets 'assets/:action/:id', :controller => 'assets', :action => 'show'
  map.account 'account/:action', :controller => 'account'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
