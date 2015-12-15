class Album < ActiveRecord::Base
  has_many :images, :inverse_of => :album
  belongs_to :poster_image, :class_name => :Image, :foreign_key => "poster_image_id"

  accepts_nested_attributes_for :images

  def url
  	"/albums/#{self.id}"
  end
end