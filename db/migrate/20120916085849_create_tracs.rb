class CreateTracs < ActiveRecord::Migration
  def change
    create_table :tracs do |t|
      t.references :topic
      t.string :target
      t.string :action
      t.text :pre_content
      t.text :post_content

      t.timestamps
    end
    add_index :tracs, :topic_id
  end
end
