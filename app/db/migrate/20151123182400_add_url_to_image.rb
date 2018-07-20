class AddUrlToImage < ActiveRecord::Migration[5.2]
  def change
  	add_column :images, :url, :string
  end
end
