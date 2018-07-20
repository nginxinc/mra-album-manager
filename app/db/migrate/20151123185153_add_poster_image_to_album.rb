class AddPosterImageToAlbum < ActiveRecord::Migration[5.2]
  def change
  	add_column :albums, :poster_image_id, :integer
  end
end
