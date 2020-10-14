class AddIndicesForImport < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :cities, :name, algorithm: :concurrently
    add_index :services, :name, algorithm: :concurrently
    add_index :buses, :number, algorithm: :concurrently
  end
end
