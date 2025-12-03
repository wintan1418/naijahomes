class AddNoteTypeToLeadNotes < ActiveRecord::Migration[7.2]
  def change
    add_column :lead_notes, :note_type, :integer, default: 0
    add_index :lead_notes, :note_type
  end
end
