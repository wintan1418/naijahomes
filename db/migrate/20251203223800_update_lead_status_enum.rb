class UpdateLeadStatusEnum < ActiveRecord::Migration[7.2]
  def up
    # Update existing leads to adjust for new enum values
    # Since we're adding 'negotiating' as 4, we need to shift closed_won and closed_lost
    execute "UPDATE leads SET status = 5 WHERE status = 4"  # closed_won: 4 -> 5
    execute "UPDATE leads SET status = 6 WHERE status = 5"  # closed_lost: 5 -> 6
  end
  
  def down
    # Reverse the status updates
    execute "UPDATE leads SET status = 4 WHERE status = 5"  # closed_won: 5 -> 4
    execute "UPDATE leads SET status = 5 WHERE status = 6"  # closed_lost: 6 -> 5
  end
end
