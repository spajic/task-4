# frozen_string_literal: true

class AddIndexToServices < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured { change_column_null :services, :name, false }
    add_index :services, :name, algorithm: :concurrently, unique: true
  end
end
