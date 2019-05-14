class AddIndiciesToTrips < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :trips, %i[from_id to_id], algorithm: :concurrently
    add_index :trips, :start_time, algorithm: :concurrently
  end
end
