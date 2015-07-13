class ChangeDoorStatusResponseColumn < ActiveRecord::Migration
  def up
    change_column :door_monitor_records, :door_response, :integer
  end
  
  def down
    change_column :door_monitor_records, :door_response, :boolean
  end
end
