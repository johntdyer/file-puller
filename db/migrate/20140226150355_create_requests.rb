class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.text :query
      t.string :email
      t.datetime :start_time
      t.datetime :end_time
      t.string :results

      t.timestamps
    end
  end
end
