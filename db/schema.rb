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

ActiveRecord::Schema.define(version: 20180519015223) do

  create_table "accounts", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "username"
    t.string   "password"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "avatar"
    t.string   "pass_reset_token"
    t.datetime "pass_reset_expiration"
    t.boolean  "email_confirmed"
    t.string   "email_confirm_token"
  end

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.datetime "start"
    t.datetime "end"
    t.boolean  "public"
    t.text     "description"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "creator"
    t.boolean  "is_group_event", default: false
    t.integer  "group_id"
  end

  add_index "events", ["creator"], name: "index_events_on_creator"

  create_table "group_join_requests", id: false, force: :cascade do |t|
    t.integer  "groups_id"
    t.integer  "accounts_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "group_members", force: :cascade do |t|
    t.integer  "accounts_id"
    t.integer  "group_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.boolean  "is_admin"
  end

  create_table "group_notifications", force: :cascade do |t|
    t.integer  "group_id"
    t.boolean  "for_all"
    t.integer  "accounts_id"
    t.string   "content"
    t.boolean  "is_read"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_tags", force: :cascade do |t|
    t.integer  "events_id"
    t.integer  "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "creator_id"
    t.string   "creator_name"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "accounts_id"
    t.string   "content"
    t.boolean  "is_read"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: :cascade do |t|
    t.integer  "events_id"
    t.integer  "accounts_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end
