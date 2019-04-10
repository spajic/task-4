class AddIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :trips, [:from_id, :to_id], algorithm: :concurrently
    add_index :trips, :bus_id, algorithm: :concurrently
    add_index :buses_services, :bus_id, algorithm: :concurrently
    add_index :buses_services, :service_id, algorithm: :concurrently
  end
end
