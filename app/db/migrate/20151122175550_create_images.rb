class CreateImages < ActiveRecord::Migration[5.2]
  def change
  	create_table :images do |t|
      t.string :name
      t.string :description

      t.timestamps null: false
    end

    add_reference(:images, :album)
  end
end