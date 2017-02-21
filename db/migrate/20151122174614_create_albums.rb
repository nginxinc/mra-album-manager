class CreateAlbums < ActiveRecord::Migration
  def change
  	create_table :albums do |t|
      t.string :name
      t.string :description
      t.string :state, null: false
      t.timestamps null: false
    end
  end
end