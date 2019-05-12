class AddForeignKeyToBusesServices < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :buses_services, :buses, column: :bus_id, on_delete: :cascade
    add_foreign_key :buses_services, :services, column: :service_id, on_delete: :cascade
  end
end
