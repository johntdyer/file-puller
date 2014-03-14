class AddMetadataToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :metadata, :string
  end
end
