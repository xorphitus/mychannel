class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.references :topic
      t.string :target, null: false
      t.string :action, null: false
      t.text :pre_content
      t.text :post_content

      t.timestamps
    end
    add_index :tracks, :topic_id
  end
end
