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

ActiveRecord::Schema.define(:version => 20110303183433) do

  create_table "access_code_requests", :force => true do |t|
    t.string   "email"
    t.datetime "code_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "access_code_requests", ["email"], :name => "index_access_code_requests_on_email"

  create_table "access_codes", :force => true do |t|
    t.string   "code"
    t.integer  "uses",       :default => 0,     :null => false
    t.boolean  "unlimited",  :default => false, :null => false
    t.datetime "expires_at"
    t.integer  "use_limit",  :default => 1,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sent_to"
  end

  add_index "access_codes", ["code"], :name => "index_access_codes_on_code"

  create_table "activities", :force => true do |t|
    t.integer  "item_id"
    t.string   "item_type"
    t.string   "template"
    t.integer  "source_id"
    t.string   "source_type"
    t.text     "content"
    t.string   "title"
    t.boolean  "is_status_update", :default => false
    t.boolean  "is_public",        :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comment_count",    :default => 0
    t.integer  "attachable_id"
    t.string   "attachable_type"
  end

  add_index "activities", ["attachable_id", "attachable_type"], :name => "index_activities_on_attachable_id_and_attachable_type"
  add_index "activities", ["item_id", "item_type"], :name => "index_activities_on_item_id_and_item_type"
  add_index "activities", ["source_id", "source_type"], :name => "index_activities_on_source_id_and_source_type"

  create_table "activity_feeds", :force => true do |t|
    t.integer "activity_id"
    t.integer "ownable_id"
    t.string  "ownable_type"
  end

  add_index "activity_feeds", ["activity_id"], :name => "index_activity_feeds_on_activity_id"
  add_index "activity_feeds", ["ownable_id", "ownable_type"], :name => "index_activity_feeds_on_ownable_id_and_ownable_type"

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id",                 :default => 0
    t.string   "commentable_type", :limit => 15, :default => ""
    t.text     "body"
    t.integer  "user_id"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "is_denied",                      :default => 0,     :null => false
    t.boolean  "is_reviewed",                    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "content_permissions", :force => true do |t|
    t.integer  "content_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_permissions", ["content_id", "user_id"], :name => "index_content_permissions_on_content_id_and_user_id"

  create_table "content_translations", :force => true do |t|
    t.integer  "content_id"
    t.string   "title"
    t.text     "body"
    t.string   "locale"
    t.boolean  "user_edited", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_translations", ["content_id"], :name => "index_content_translations_on_content_id"
  add_index "content_translations", ["locale"], :name => "index_content_translations_on_locale"

  create_table "contents", :force => true do |t|
    t.integer  "creator_id"
    t.string   "title"
    t.text     "body"
    t.string   "locale"
    t.text     "body_raw"
    t.integer  "contentable_id"
    t.string   "contentable_type"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.boolean  "is_public"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "layout"
    t.integer  "comment_count",    :default => 0
    t.string   "cached_slug"
  end

  add_index "contents", ["cached_slug"], :name => "index_contents_on_cached_slug"
  add_index "contents", ["creator_id"], :name => "index_contents_on_creator_id"
  add_index "contents", ["parent_id"], :name => "index_contents_on_parent_id"

  create_table "countries", :force => true do |t|
    t.string  "name",         :limit => 128, :default => "",   :null => false
    t.string  "abbreviation", :limit => 3,   :default => "",   :null => false
    t.integer "sort",                        :default => 1000, :null => false
  end

  add_index "countries", ["abbreviation"], :name => "index_countries_on_abbreviation"
  add_index "countries", ["name"], :name => "index_countries_on_name"

  create_table "domain_themes", :force => true do |t|
    t.string "uri"
    t.string "name"
  end

  add_index "domain_themes", ["uri"], :name => "index_domain_themes_on_uri"

  create_table "friends", :force => true do |t|
    t.integer  "inviter_id"
    t.integer  "invited_id"
    t.integer  "status",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friends", ["invited_id", "inviter_id"], :name => "index_friends_on_invited_id_and_inviter_id"
  add_index "friends", ["inviter_id", "invited_id"], :name => "index_friends_on_inviter_id_and_invited_id"

  create_table "languages", :force => true do |t|
    t.string  "name"
    t.string  "english_name"
    t.string  "locale"
    t.boolean "supported",    :default => true
    t.boolean "is_default",   :default => false
  end

  add_index "languages", ["locale"], :name => "index_languages_on_locale"
  add_index "languages", ["name"], :name => "index_languages_on_name"

  create_table "permissions", :force => true do |t|
    t.integer  "role_id",    :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location"
    t.decimal  "lat",                :precision => 15, :scale => 10
    t.decimal  "lng",                :precision => 15, :scale => 10
    t.text     "about"
    t.string   "city"
    t.integer  "state_id"
    t.integer  "country_id"
    t.integer  "language_id"
    t.integer  "profile_views"
    t.text     "policy"
  end

  add_index "profiles", ["lat", "lng"], :name => "index_profiles_on_lat_and_lng"
  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "roles", :force => true do |t|
    t.string   "rolename"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", :force => true do |t|
    t.string  "name",         :limit => 128, :default => "", :null => false
    t.string  "abbreviation", :limit => 3,   :default => "", :null => false
    t.integer "country_id",   :limit => 8,                   :null => false
  end

  add_index "states", ["abbreviation"], :name => "index_states_on_abbreviation"
  add_index "states", ["country_id"], :name => "index_states_on_country_id"
  add_index "states", ["name"], :name => "index_states_on_name"

  create_table "themes", :force => true do |t|
    t.string "name"
  end

  create_table "uploads", :force => true do |t|
    t.integer  "creator_id"
    t.string   "name"
    t.string   "caption",             :limit => 1000
    t.text     "description"
    t.boolean  "is_public",                           :default => true
    t.integer  "uploadable_id"
    t.string   "uploadable_type"
    t.string   "width"
    t.string   "height"
    t.string   "local_file_name"
    t.string   "local_content_type"
    t.integer  "local_file_size"
    t.datetime "local_updated_at"
    t.string   "remote_file_name"
    t.string   "remote_content_type"
    t.integer  "remote_file_size"
    t.datetime "remote_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "uploads", ["creator_id"], :name => "index_uploads_on_creator_id"
  add_index "uploads", ["local_content_type"], :name => "index_uploads_on_local_content_type"
  add_index "uploads", ["uploadable_id"], :name => "index_uploads_on_uploadable_id"
  add_index "uploads", ["uploadable_type"], :name => "index_uploads_on_uploadable_type"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",                      :null => false
    t.string   "single_access_token",                    :null => false
    t.string   "perishable_token",                       :null => false
    t.integer  "login_count",         :default => 0,     :null => false
    t.integer  "failed_login_count",  :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.boolean  "terms_of_service",    :default => false, :null => false
    t.string   "time_zone",           :default => "UTC"
    t.datetime "disabled_at"
    t.datetime "created_at"
    t.datetime "activated_at"
    t.datetime "updated_at"
    t.string   "identity_url"
    t.string   "url_key"
    t.integer  "access_code_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

end
