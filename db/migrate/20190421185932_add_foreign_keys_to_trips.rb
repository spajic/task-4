# frozen_string_literal: true

class AddForeignKeysToTrips < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_foreign_key :trips, :cities, column: :to_id
    add_foreign_key :trips, :cities, column: :from_id
  end
end
