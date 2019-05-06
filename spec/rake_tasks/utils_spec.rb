require 'rails_helper'
require 'rake'

describe 'stats:fix_all'do
  before do
    Rake.application.rake_require 'tasks/utils'
    Rake::Task.define_task(:environment)
  end

  subject(:task) { Rake::Task["reload_json"].invoke('fixtures/example.json') }

  it 'creates data' do
    expect { task }.to change(Bus, :count).by(1)
                   .and(change(Trip, :count).by(10))
                   .and(change(City, :count).by(2))
                   .and(change(Service, :count).by(Service::SERVICES.size))
  end
end
