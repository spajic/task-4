require 'rails_helper'
require 'rspec-sqlimit'
require 'rake'
require 'capybara/rails'
require 'benchmark'
load 'Rakefile'

describe "trips index view", type: :feature do
  before do
    Rake::Task['reload_json'].reenable
    Rake::Task['reload_json'].invoke('fixtures/large.json')
  end
  let!(:trip) { Trip.preload(:from, :to).take }

  it 'correct trips count' do
    visit URI.parse(URI.escape("/автобусы/#{trip.from.name}/#{trip.to.name}"))
    expect(page).to have_selector('.trip-item', count: 9)
    expect(page).to have_selector('.service-item', count: 48)
  end


  # large 2.6, with preload 0.65
  it 'run in time' do
    time = Benchmark.realtime do
      visit URI.parse(URI.escape("/автобусы/#{trip.from.name}/#{trip.to.name}"))
    end

    puts "Render time: #{time}"

    expect(time).to be <  0.015
  end

  # small 22, with preload 6
  it "doesn't send unnecessary requests to db" do
    expect { visit URI.parse(URI.escape("/автобусы/#{trip.from.name}/#{trip.to.name}")) }.not_to exceed_query_limit(6)
  end
end
