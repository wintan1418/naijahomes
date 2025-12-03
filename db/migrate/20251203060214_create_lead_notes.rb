class CreateLeadNotes < ActiveRecord::Migration[7.2]
  def change
    create_table :lead_notes do |t|
      t.references :lead, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
