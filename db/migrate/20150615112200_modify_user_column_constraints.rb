class ModifyUserColumnConstraints < ActiveRecord::Migration
  def up
    # Remove the non-null constraint on email
    change_column :users, :email, :string, null: true
  end

  def down
    change_column :users, :email, :string, null: false
  end
end
