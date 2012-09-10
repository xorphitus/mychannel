class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.references :user
      t.string :name
      t.boolean :publish_flag
      t.text :description

      t.timestamps
    end
    add_index :channels, :user_id
  end
end
