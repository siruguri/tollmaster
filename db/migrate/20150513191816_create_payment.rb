class CreatePayment < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :payment_token_record_id
      t.integer :amount
      t.datetime :payment_date
      t.string :payment_for

      t.timestamps
    end
  end
end
