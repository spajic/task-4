class TripsController < ApplicationController
  def index
    @from = City.find_by_name!(params[:from])
    @to = City.find_by_name!(params[:to])
    @trips = Trip.preload(:bus, :services)
                 .where(from: @from, to: @to)
                 .select_finish_time
                 .order(:start_time)#.load
  end
end
