#
#  image.rb
#  AlbumManager
#
# The Album ActiveRecord model
#  Copyright © 2017 NGINX Inc. All rights reserved.
#

class Image < ActiveRecord::Base
  belongs_to :album, :inverse_of => :images
  validates_presence_of :album
end