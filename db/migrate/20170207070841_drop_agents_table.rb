class DropAgentsTable < ActiveRecord::Migration
  def change
    drop_table :agents
    drop_table :status
  end
end
