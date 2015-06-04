class CreateDoorMonitorRecords < ActiveRecord::Migration
  def change
    create_table :door_monitor_records do |t|
      t.integer :requestor_id
      t.boolean :door_response

      t.timestamps
    end
  end
end
