class CreateProperties < ActiveRecord::Migration[7.2]
  def change
    create_table :properties do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description, null: false
      t.decimal :price, null: false, precision: 10, scale: 2
      t.integer :payment_frequency, null: false, default: 0
      t.integer :property_type, null: false
      t.integer :bedrooms
      t.integer :bathrooms
      t.integer :toilets
      t.decimal :size, precision: 10, scale: 2
      t.string :state, null: false
      t.string :city, null: false
      t.string :lga
      t.string :address, null: false
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.integer :status, null: false, default: 0
      t.boolean :featured, default: false

      t.timestamps
    end
    
    add_index :properties, :state
    add_index :properties, :city
    add_index :properties, :status
    add_index :properties, :property_type
    add_index :properties, :price
    add_index :properties, [:latitude, :longitude]
    add_index :properties, :featured
  end
end
