class AddConfirmableColumnsToDeviseUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      ## Confirmable
      t.string   :confirmation_token
      t.string   :unconfirmed_email
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
    end
  end
end
