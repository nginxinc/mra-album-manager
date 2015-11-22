class Album < ActiveRecord::Base
  validates_presence_of :name

  has_many :images
end