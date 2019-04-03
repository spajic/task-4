# frozen_string_literal: true

require 'rails_helper'
require 'rspec-sqlimit'
require 'rake'
require 'benchmark'
load 'Rakefile'

EXAMPLE_JSON_FILE = 'fixtures/example.json'
ACTUAL_JSON = 'fixtures/large.json'
TIMING = {
  'fixtures/small.json' => 0.5,
  'fixtures/medium.json' => 3.0,
  'fixtures/large.json' => 30
}.freeze

describe 'Rake tasks' do
  before { Rake::Task['reload_json'].reenable }
  task = Rake::Task['reload_json']

  it 'correct work' do
    task.invoke(EXAMPLE_JSON_FILE)
    expect(City.count).to eq(2)
    expect(Service.count).to eq(2)
    expect(Trip.count).to eq(10)
    expect(Bus.count).to eq(1)
    expect(BusesService.count).to eq(2)
    expect(Bus.first.services.size).to eq(2)
  end

  it 'run in time' do
    time = Benchmark.realtime do
      task.invoke(ACTUAL_JSON)
    end

    puts "Task time: #{time}"

    expect(time).to be < TIMING[ACTUAL_JSON]
  end

  it "doesn't send unnecessary requests to db" do
    expect { task.invoke(EXAMPLE_JSON_FILE) }.not_to exceed_query_limit(12)
  end
end
