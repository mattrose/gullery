class Asset < ActiveRecord::Base

  validates_presence_of :project_id, :path
  validates_associated :project

  belongs_to :project
    
  acts_as_taggable

end
