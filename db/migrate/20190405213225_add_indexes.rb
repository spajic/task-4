class AddIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :cities, :name, unique: true
    add_index :buses, :number, unique: true
    add_index :services, :name, unique: true
    add_index :buses_services, [:bus_id, :service_id], unique: true

    change_column_null :trips, :from_id, false
    change_column_null :trips, :to_id, false
    change_column_null :trips, :bus_id, false
    change_column_null :trips, :duration_minutes, false
    change_column_null :trips, :price_cents, false

    add_index :trips, [:from_id, :to_id]
  end
end
