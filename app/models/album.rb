#
# album.rb
# AlbumManager
#
# The Album ActiveRecord model
#
# Copyright © 2017 NGINX Inc. All rights reserved.
#
class Album < ActiveRecord::Base
  has_many :images, :inverse_of => :album
  belongs_to :poster_image, :class_name => :Image, :foreign_key => 'poster_image_id'

  accepts_nested_attributes_for :images

  #
  # Generate the URL for an album by concatenating the ID: /albums/XXX
  #
  def url
    "/albums/#{self.id}"
  end
end