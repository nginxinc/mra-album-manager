class AddSizesToImage < ActiveRecord::Migration
  def change
  	add_column :images, :thumb_url, :string
  	add_column :images, :thumb_height, :integer
  	add_column :images, :thumb_width, :integer

  	add_column :images, :medium_url, :string
  	add_column :images, :medium_height, :integer
  	add_column :images, :medium_width, :integer

  	add_column :images, :large_url, :string
  	add_column :images, :large_height, :integer
  	add_column :images, :large_width, :integer
  end
end
