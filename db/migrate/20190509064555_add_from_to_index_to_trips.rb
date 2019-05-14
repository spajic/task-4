class AddFromToIndexToTrips < ActiveRecord::Migration[5.2]
  def change
    add_index :trips, [:from_id, :to_id, :start_time], order: { start_time: :asc }
  end
end
