class AddDisabledToPaymentTokenRecord < ActiveRecord::Migration
  def change
    add_column :payment_token_records, :disabled, :boolean, default: false
  end
end
