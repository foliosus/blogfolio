# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090210085042) do

  create_table "categories", :force => true do |t|
    t.string   "name",       :limit => 25, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",       :limit => 25
  end

  create_table "categories_posts", :id => false, :force => true do |t|
    t.integer  "category_id", :null => false
    t.integer  "post_id",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clients", :force => true do |t|
    t.string   "name",       :limit => 80,  :null => false
    t.string   "slug",       :limit => 80,  :null => false
    t.text     "teaser",                    :null => false
    t.text     "content",                   :null => false
    t.string   "url",        :limit => 120
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "post_id",                  :null => false
    t.string   "author",     :limit => 60, :null => false
    t.string   "email",      :limit => 60, :null => false
    t.string   "homepage",   :limit => 60
    t.text     "body",                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["post_id"], :name => "fk_comments_post"

  create_table "pages", :force => true do |t|
    t.string   "url",               :null => false
    t.string   "name",              :null => false
    t.string   "description",       :null => false
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "secondary_content"
  end

  create_table "photos", :force => true do |t|
    t.string   "title",         :limit => 250, :null => false
    t.text     "caption"
    t.string   "filename",      :limit => 250, :null => false
    t.integer  "width",                        :null => false
    t.integer  "height",                       :null => false
    t.string   "content_type",  :limit => 100
    t.datetime "image_date",                   :null => false
    t.string   "keywords",      :limit => 250
    t.integer  "aperture"
    t.string   "focal_length",  :limit => 11
    t.string   "shutter_speed", :limit => 8
    t.integer  "speed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.string   "title",        :limit => 120,                :null => false
    t.text     "content"
    t.string   "permalink",    :limit => 200
    t.integer  "status_id",                   :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "role",                      :limit => 20, :default => "none"
  end

end
