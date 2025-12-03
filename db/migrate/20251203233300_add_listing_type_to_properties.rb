class AddListingTypeToProperties < ActiveRecord::Migration[7.2]
  def change
    add_column :properties, :listing_type, :integer, default: 0
    add_index :properties, :listing_type
  end
end
