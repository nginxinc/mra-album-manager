class Album < ActiveRecord::Base
  validates_presence_of :name

  has_many :images
  belongs_to :poster_image, :class_name => :Image, :foreign_key => "poster_image_id"

  accepts_nested_attributes_for :images

  def url
  	"/albums/#{self.id}/"
  end
end