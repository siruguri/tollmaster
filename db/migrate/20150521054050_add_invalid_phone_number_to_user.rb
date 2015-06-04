class AddInvalidPhoneNumberToUser < ActiveRecord::Migration
  def change
    add_column :users, :invalid_phone_number, :boolean
  end
end
