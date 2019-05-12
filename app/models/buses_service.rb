class BusesService < ApplicationRecord
  belongs_to :bus, foreign_key: :bus_id
  belongs_to :service, foreign_key: :service_id
end