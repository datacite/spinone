class AddStatusTable < ActiveRecord::Migration
  def up
    create_table(:status) do |t|
      t.string   "uuid",                    limit: 191
      t.integer  "datacite_orcid_count",    limit: 4,   default: 0
      t.integer  "datacite_github_count",   limit: 4,   default: 0
      t.integer  "datacite_related_count",  limit: 4,   default: 0
      t.integer  "orcid_update_count",      limit: 4,   default: 0
      t.integer  "db_size",                 limit: 8,   default: 0
      t.string   "version",                 limit: 255
      t.string   "current_version",         limit: 255
      t.datetime "created_at",                                      null: false
      t.datetime "updated_at",                                      null: false
    end

    add_index "status", ["created_at"], name: "index_status_created_at"
  end

  def down
    drop_table :status
  end
end
