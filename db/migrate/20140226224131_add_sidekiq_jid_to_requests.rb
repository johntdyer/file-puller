class AddSidekiqJidToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :jid, :string
  end
end
