class AddStateToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :state, :string, null: false, default: 'pending', index: true
  end
end
