class CreateAlbums < ActiveRecord::Migration[5.2]
  def change
  	create_table :albums do |t|
      t.string :name
      t.string :description
      t.timestamps null: false
    end
  end
end
