class Image < ActiveRecord::Base
  belongs_to :album, :inverse_of => :images
  validates_presence_of :album
end