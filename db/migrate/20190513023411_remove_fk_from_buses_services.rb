class RemoveFkFromBusesServices < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :buses_services, column: :bus_id
    remove_foreign_key :buses_services, column: :service_id
  end
end
