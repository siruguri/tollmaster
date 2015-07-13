class AddIsInternationalToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_international, :boolean
  end
end
