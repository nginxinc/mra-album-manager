class AddUserIdToAlbum < ActiveRecord::Migration
  def change
  	add_column :albums, :user_id, :string
  end
end
