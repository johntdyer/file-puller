class AddLogToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :log, :string
  end
end
