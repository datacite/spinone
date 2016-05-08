class AddAgentsTable < ActiveRecord::Migration
  def change
    create_table(:agents) do |t|
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
  end
end
