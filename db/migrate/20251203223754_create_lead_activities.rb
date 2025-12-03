class CreateLeadActivities < ActiveRecord::Migration[7.2]
  def change
    create_table :lead_activities do |t|
      t.references :lead, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :activity_type
      t.text :description
      t.json :details

      t.timestamps
    end
  end
end
