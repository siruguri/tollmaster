class CreatePaymentTokenRecord < ActiveRecord::Migration
  def change
    create_table :payment_token_records do |t|
      t.integer :user_id
      t.string :token_processor
      t.string :token_value

      t.timestamps
    end
  end
end
