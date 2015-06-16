class ModifyIndexOnUsers < ActiveRecord::Migration
  def up
    # Remove the null constraint on email
    remove_index :users, :email
    add_index :users, :email
  end

  def down
    # Remove the null constraint on email
    remove_index :users, :email
    add_index :users, :email, unique: true
  end
end
