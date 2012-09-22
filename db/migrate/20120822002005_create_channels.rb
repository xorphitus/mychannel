class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.references :user, null: false
      t.string :name, null: false
      t.boolean :publish_flag, null: false, default:false
      t.text :description

      t.timestamps
    end
    add_index :channels, :user_id
  end
end
