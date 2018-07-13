class AddPublicToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :public, :boolean, null: false, default: false, index: true
  end
end
