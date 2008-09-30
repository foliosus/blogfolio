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

ActiveRecord::Schema.define(:version => 20080921234702) do

  create_table "classifieds", :force => true do |t|
    t.string   "title",                     :default => "", :null => false
    t.text     "description",                               :null => false
    t.string   "url"
    t.string   "email"
    t.string   "phone",       :limit => 10
    t.text     "contact",                                   :null => false
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string   "name",        :default => "", :null => false
    t.text     "description",                 :null => false
    t.string   "location"
    t.date     "the_date",                    :null => false
    t.string   "the_time",    :default => "", :null => false
    t.string   "contact"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "member_updates", :force => true do |t|
    t.string   "first_name",  :limit => 40
    t.string   "last_name",   :limit => 40
    t.string   "phone",       :limit => 10
    t.string   "email",       :limit => 60
    t.string   "address",     :limit => 60
    t.string   "address2",    :limit => 60
    t.string   "city",        :limit => 25
    t.string   "state",       :limit => 2
    t.string   "zip",         :limit => 5
    t.boolean  "volunteer"
    t.boolean  "speaker"
    t.integer  "category_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", :force => true do |t|
    t.string   "first_name", :limit => 40, :default => "",    :null => false
    t.string   "last_name",  :limit => 40, :default => "",    :null => false
    t.string   "phone",      :limit => 10
    t.string   "email",      :limit => 60
    t.string   "address",    :limit => 60, :default => "",    :null => false
    t.string   "address2",   :limit => 60
    t.string   "city",       :limit => 25, :default => "",    :null => false
    t.string   "state",      :limit => 2,  :default => "OR",  :null => false
    t.string   "zip",        :limit => 5,  :default => "",    :null => false
    t.boolean  "volunteer",                :default => false, :null => false
    t.boolean  "speaker",                  :default => false, :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id"
    t.string   "category",                 :default => "new", :null => false
    t.text     "notes"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "member_id",                   :null => false
    t.integer  "year",                        :null => false
    t.integer  "payment",     :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "member_type", :default => "", :null => false
  end

  create_table "news_items", :force => true do |t|
    t.string   "name",        :default => "", :null => false
    t.text     "description",                 :null => false
    t.date     "the_date",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "newsletters", :force => true do |t|
    t.date     "the_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "url",         :default => "", :null => false
    t.string   "name",        :default => "", :null => false
    t.string   "description", :default => "", :null => false
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schools", :force => true do |t|
    t.string   "name",             :limit => 60,                                :default => "",    :null => false
    t.string   "phone",            :limit => 10
    t.string   "email",            :limit => 60
    t.string   "url",              :limit => 60
    t.string   "address",          :limit => 60,                                :default => "",    :null => false
    t.string   "address2",         :limit => 60
    t.string   "city",             :limit => 25,                                :default => "",    :null => false
    t.string   "state",            :limit => 2,                                 :default => "OR",  :null => false
    t.string   "zip",              :limit => 5,                                 :default => "",    :null => false
    t.boolean  "contact_by_email",                                              :default => true,  :null => false
    t.boolean  "volunteer",                                                     :default => false, :null => false
    t.boolean  "speaker",                                                       :default => false, :null => false
    t.integer  "infants",                                                       :default => 0
    t.integer  "primary",                                                       :default => 0
    t.integer  "lower_elementary",                                              :default => 0
    t.integer  "upper_elementary",                                              :default => 0
    t.integer  "high_school",                                                   :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "latitude",                       :precision => 11, :scale => 7,                    :null => false
    t.decimal  "longitude",                      :precision => 11, :scale => 7,                    :null => false
    t.string   "category"
    t.text     "notes"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                     :limit => 100, :default => "",   :null => false
    t.string   "crypted_password",          :limit => 40,  :default => "",   :null => false
    t.string   "salt",                      :limit => 40,  :default => "",   :null => false
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "role",                      :limit => 12
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "force_password_reset",                     :default => true
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
