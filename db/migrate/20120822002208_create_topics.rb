class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.references :channel
      t.string :name
      t.string :target
      t.text :target_text
      t.integer :order

      t.timestamps
    end
    add_index :topics, :channel_id
  end
end
