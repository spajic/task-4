# frozen_string_literal: true

class AddIndexToBusesService < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :buses_services, %i[bus_id service_id], algorithm: :concurrently, unique: true
  end
end
