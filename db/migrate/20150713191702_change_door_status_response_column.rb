class ChangeDoorStatusResponseColumn < ActiveRecord::Migration
  def up
    change_column :door_monitor_records, :door_response, 'integer USING CAST(door_response AS integer)'
  end
  
  def down
    change_column :door_monitor_records, :door_response, 'boolean USING CAST(door_response AS boolean)'
  end
end
