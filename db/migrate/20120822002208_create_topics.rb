class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.references :channel
      t.string :name, null: false
      t.string :target, null: false
      t.text :target_text
      t.integer :order, null: false, default: 0

      t.timestamps
    end
    add_index :topics, :channel_id
  end
end
