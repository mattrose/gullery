require File.dirname(__FILE__) + '/../../test_helper'

class ApplicationHelperTest < HelperTestCase

  include ApplicationHelper

  fixtures :users

  def setup
    super
  end

  def test_show_page_nav
    output = show_page_nav
    assert_match %r{Cloneberry International}, output
  end
  
end
