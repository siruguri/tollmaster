class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :user_id
      t.float :amount
      t.integer :invoice_status
      t.datetime :pay_by
    end
  end
end
