class AddCrmFieldsToLeads < ActiveRecord::Migration[7.2]
  def change
    add_column :leads, :priority, :integer
    add_column :leads, :lead_source, :integer
    add_column :leads, :budget, :decimal
    add_column :leads, :lost_reason, :text
  end
end
