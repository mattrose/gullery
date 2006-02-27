class Project < ActiveRecord::Base

  validates_presence_of :user_id, :name
  validates_associated :user

  belongs_to :user
  has_many :assets

  acts_as_taggable

end
