class AddForeignKeyToTrips < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :trips, :cities, column: :from_id, on_delete: :cascade
    add_foreign_key :trips, :cities, column: :to_id, on_delete: :cascade
  end
end
