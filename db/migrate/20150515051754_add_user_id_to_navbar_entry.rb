class AddUserIdToNavbarEntry < ActiveRecord::Migration
  def change
    add_column :navbar_entries, :user_id, :integer
  end
end
