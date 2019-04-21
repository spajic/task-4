# frozen_string_literal: true

class AddIndexToTrips < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_foreign_key :trips, :buses
    add_index :trips, :start_time, algorithm: :concurrently, order: { start_time: :asc }
    add_index :trips, :bus_id, algorithm: :concurrently
    add_index :trips, :from_id, algorithm: :concurrently
    add_index :trips, :to_id, algorithm: :concurrently
  end
end
