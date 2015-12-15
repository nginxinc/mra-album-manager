class Image < ActiveRecord::Base
  belongs_to :album
  validates_presence_of :album
end