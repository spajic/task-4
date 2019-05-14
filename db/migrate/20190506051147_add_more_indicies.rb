class AddMoreIndicies < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :cities, :name, unique: true, algorithm: :concurrently
    add_index :buses, :number, unique: true, algorithm: :concurrently
    add_index :services, :name, unique: true, algorithm: :concurrently
  end
end
