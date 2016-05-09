class AddUsersTable < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.string   :name,                   limit: 191
      t.string   :email,                  limit: 191
      t.string   :provider,               limit: 255
      t.string   :uid,                    limit: 191
      t.string   :authentication_token,   limit: 191
      t.string   :api_key,                limit: 191
      t.string   :role,                   limit: 255, default: 'user'
      t.timestamps
    end

    add_index :users, :uid,               unique: true
  end
end
