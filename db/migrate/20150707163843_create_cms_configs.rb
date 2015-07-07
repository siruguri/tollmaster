class CreateCmsConfigs < ActiveRecord::Migration
  def change
    create_table :cms_configs do |t|
      t.string :source_symbol
      t.text :target_text
    end
  end
end
