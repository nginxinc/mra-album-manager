class AddStateToAlbums < ActiveRecord::Migration[5.2]
  def change
    add_column :albums, :state, :string, null: false, default: 'pending', index: true
  end
end
