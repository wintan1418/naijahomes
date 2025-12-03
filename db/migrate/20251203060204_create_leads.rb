class CreateLeads < ActiveRecord::Migration[7.2]
  def change
    create_table :leads do |t|
      t.references :property, null: false, foreign_key: true
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.text :message, null: false
      t.string :source, null: false, default: 'web_form'
      t.integer :status, null: false, default: 0
      t.datetime :follow_up_at

      t.timestamps
    end
    
    add_index :leads, :status
    add_index :leads, :created_at
  end
end
