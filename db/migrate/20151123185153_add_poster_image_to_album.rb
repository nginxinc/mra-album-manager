class AddPosterImageToAlbum < ActiveRecord::Migration
  def change
  	add_column :albums, :poster_image_id, :integer
  end
end
