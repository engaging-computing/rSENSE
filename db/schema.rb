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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160128175730) do

  create_table "contrib_keys", force: true do |t|
    t.string   "name",       null: false
    t.string   "key",        null: false
    t.integer  "project_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_sets", force: true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "googleDoc"
    t.text     "data",             default: "[]", null: false
    t.string   "key"
    t.string   "contributor_name"
  end

  create_table "fields", force: true do |t|
    t.string   "name"
    t.integer  "field_type"
    t.text     "unit",         limit: 255, default: ""
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "restrictions",             default: "[]"
    t.integer  "index"
  end

  create_table "likes", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "media_objects", force: true do |t|
    t.integer  "project_id"
    t.string   "media_type"
    t.string   "name"
    t.integer  "data_set_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tutorial_id"
    t.boolean  "hidden",           default: false
    t.integer  "visualization_id"
    t.integer  "news_id"
    t.string   "store_key"
    t.string   "file"
    t.string   "md5"
  end

  create_table "news", force: true do |t|
    t.string   "title"
    t.text     "content"
    t.text     "summary"
    t.boolean  "hidden",            default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "featured_media_id"
  end

  create_table "projects", force: true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "featured",                      default: false
    t.text     "filter",            limit: 255, default: ""
    t.integer  "cloned_from"
    t.boolean  "is_template",                   default: false
    t.integer  "featured_media_id"
    t.boolean  "hidden",                        default: false
    t.datetime "featured_at"
    t.boolean  "lock",                          default: false
    t.boolean  "curated",                       default: false
    t.datetime "curated_at"
    t.text     "default_vis"
    t.integer  "precision",                     default: 4
    t.text     "globals"
    t.text     "kml_metadata"
  end

  create_table "tutorials", force: true do |t|
    t.text     "content"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "hidden",            default: true
    t.integer  "featured_media_id"
    t.boolean  "featured",          default: false
    t.datetime "featured_at"
  end

  create_table "users", force: true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.integer  "group_id"
    t.boolean  "validated",       default: false
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "validation_key"
    t.boolean  "admin",           default: false
    t.boolean  "hidden",          default: false
    t.text     "bio"
    t.integer  "news_id"
    t.datetime "last_login",      default: '2013-08-16 12:00:00'
    t.string   "name"
  end

  create_table "view_counts", force: true do |t|
    t.integer  "project_id",             null: false
    t.integer  "count",      default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "visualizations", force: true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.integer  "project_id"
    t.text     "content"
    t.text     "data"
    t.text     "globals"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",      default: false
    t.boolean  "featured",    default: false
    t.datetime "featured_at"
    t.text     "summary"
    t.integer  "thumb_id"
  end

end
