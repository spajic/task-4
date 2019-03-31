require 'rails_helper'
require 'rspec-sqlimit'
require 'rake'
require 'benchmark'
load 'Rakefile'

RSpec.describe TripsController, type: :controller do
  before do
    Rake::Task['reload_json'].reenable
    Rake::Task['reload_json'].invoke('fixtures/small.json')
  end
  let!(:trip) { Trip.preload(:from, :to).take }

  it 'correct trips count' do
    get :index, params: { from: trip.from.name , to: trip.to.name }
    expect(assigns(:trips).size).to eq(9)
    expect(assigns(:from).name).to eq(trip.from.name)
    expect(assigns(:to).name).to eq(trip.to.name)
    end


  it 'run in time' do
    time = Benchmark.realtime do
      get :index, params: { from: trip.from.name , to: trip.to.name }
    end

    puts "Controller time: #{time}"

    expect(time).to be <  0.006
  end

  it "doesn't send unnecessary requests to db" do
    expect { get :index, params: { from: trip.from.name , to: trip.to.name } }.not_to exceed_query_limit(2)
  end
end
