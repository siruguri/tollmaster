class ChangeUserIdColumnInInvoiceToPayerId < ActiveRecord::Migration
  def change
    rename_column :invoices, :user_id, :payer_id
  end
end
