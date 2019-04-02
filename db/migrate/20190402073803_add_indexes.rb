class AddIndexes < ActiveRecord::Migration[5.2]
  def change

    add_index :cities, %i[id name]
    add_index :trips, %i[id from_id to_id]
    add_index :buses, %i[id number model]
    add_index :buses_services, %i[id bus_id service_id]
    add_index :services, %i[id name]
  end
end
