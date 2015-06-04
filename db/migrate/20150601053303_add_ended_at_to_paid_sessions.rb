class AddEndedAtToPaidSessions < ActiveRecord::Migration
  def change
    add_column :paid_sessions, :ended_at, :datetime
  end
end
