class AddInvoiceIdToPaidSession < ActiveRecord::Migration
  def change
    add_column :paid_sessions, :invoice_id, :integer
  end
end
