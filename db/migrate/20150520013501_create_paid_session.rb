class CreatePaidSession < ActiveRecord::Migration
  def change
    create_table :paid_sessions do |t|
      t.integer :user_id
      t.datetime :started_at
      t.boolean :active

      t.timestamps
    end
  end
end
