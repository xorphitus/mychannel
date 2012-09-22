# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120916085849) do

  create_table "channels", :force => true do |t|
    t.integer  "user_id",                         :null => false
    t.string   "name",                            :null => false
    t.boolean  "publish_flag", :default => false, :null => false
    t.text     "description"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "channels", ["user_id"], :name => "index_channels_on_user_id"

  create_table "topics", :force => true do |t|
    t.integer  "channel_id"
    t.string   "name",                       :null => false
    t.string   "target",                     :null => false
    t.text     "target_text"
    t.integer  "order",       :default => 0, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "topics", ["channel_id"], :name => "index_topics_on_channel_id"

  create_table "tracs", :force => true do |t|
    t.integer  "topic_id"
    t.string   "target",       :null => false
    t.string   "action",       :null => false
    t.text     "pre_content"
    t.text     "post_content"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "tracs", ["topic_id"], :name => "index_tracs_on_topic_id"

  create_table "users", :force => true do |t|
    t.string   "fb_id",      :null => false
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "users", ["fb_id"], :name => "index_users_on_fb_id", :unique => true
  add_index "users", ["name"], :name => "index_users_on_name", :unique => true

end
