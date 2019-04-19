# frozen_string_literal: true

require 'rails_helper'

describe ImportTripsService do
  subject { ImportTripsService.load('fixtures/example.json') }

  it 'corrects import trips', :aggregate_failures do
    subject
    expect(City.count).to eq 2
    expect(Trip.count).to eq 10
    expect(Service.count).to eq 2
    expect(Bus.count).to eq 1
  end

  it 'has constant number of requests to DB' do
    expect { subject }.not_to exceed_query_limit(96)
  end
end
