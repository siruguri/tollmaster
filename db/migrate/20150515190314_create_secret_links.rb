class CreateSecretLinks < ActiveRecord::Migration
  def change
    create_table :secret_links do |t|
      t.integer :user_id
      t.string :secret

      t.timestamps
    end
  end
end
