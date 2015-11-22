class Image < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :album
end