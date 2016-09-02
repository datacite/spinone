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

ActiveRecord::Schema.define(version: 20160901124957) do

  create_table "agents", force: :cascade do |t|
    t.string   "type",        limit: 191
    t.string   "name",        limit: 191
    t.string   "title",       limit: 255,                                   null: false
    t.text     "description", limit: 65535
    t.integer  "state",       limit: 4,     default: 0
    t.string   "state_event", limit: 255
    t.text     "config",      limit: 65535
    t.datetime "run_at",                    default: '1970-01-01 00:00:00', null: false
    t.datetime "last_run_at",               default: '1970-01-01 00:00:00', null: false
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.string   "uuid",        limit: 255
  end

  create_table "status", force: :cascade do |t|
    t.string   "uuid",                   limit: 191
    t.integer  "datacite_orcid_count",   limit: 4,   default: 0
    t.integer  "datacite_github_count",  limit: 4,   default: 0
    t.integer  "datacite_related_count", limit: 4,   default: 0
    t.integer  "orcid_update_count",     limit: 4,   default: 0
    t.integer  "db_size",                limit: 8,   default: 0
    t.string   "version",                limit: 255
    t.string   "current_version",        limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "status", ["created_at"], name: "index_status_created_at", using: :btree

end
