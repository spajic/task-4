class TripsController < ApplicationController
  def index
    @from = City.find_by_name!(params[:from])
    @to = City.find_by_name!(params[:to])
    @trips = Trip.where(from: @from, to: @to)
                 .eager_load(bus: :services)
                 .order(:start_time)
  end
end
