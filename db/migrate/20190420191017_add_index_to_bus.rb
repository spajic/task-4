# frozen_string_literal: true

class AddIndexToBus < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured { change_column_null :buses, :number, false }
    add_index :buses, :number, algorithm: :concurrently, unique: true
  end
end
