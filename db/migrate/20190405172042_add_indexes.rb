class AddIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :buses_services, :bus_id
    add_index :buses_services, :service_id
    add_index :cities, :name
    add_index :trips, :bus_id
    add_index :trips, [:from_id, :to_id]
  end
end
