class AddPublicToAlbums < ActiveRecord::Migration[5.2]
  def change
    add_column :albums, :public, :boolean, null: false, default: false, index: true
  end
end
