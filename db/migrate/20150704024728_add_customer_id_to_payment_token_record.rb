class AddCustomerIdToPaymentTokenRecord < ActiveRecord::Migration
  def change
    add_column :payment_token_records, :customer_id, :string
  end
end
