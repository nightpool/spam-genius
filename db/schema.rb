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

ActiveRecord::Schema.define(version: 20150420164043) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_links", id: false, force: :cascade do |t|
    t.integer "self"
    t.integer "other"
  end

  add_index "account_links", ["other"], name: "index_account_links_on_other", using: :btree
  add_index "account_links", ["self"], name: "index_account_links_on_self", using: :btree

  create_table "accounts", force: :cascade do |t|
    t.integer  "is_spammer", default: 0
    t.string   "name"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "created"
    t.string   "photo"
  end

  add_index "accounts", ["id"], name: "index_accounts_on_id", unique: true, using: :btree

  create_table "downvotes", force: :cascade do |t|
    t.integer  "by_user"
    t.integer  "of_user"
    t.integer  "thread"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
