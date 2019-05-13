require 'rails_helper'

RSpec.describe TripsController, type: :controller do
  describe 'GET #index' do
    before do
      JsonImporter.new().import_json_to_db(file_path: 'spec/fixtures/data.json')
      get :index, params: { from: 'Сочи', to: 'Тула'}
    end

    it 'populates correct data' do 
      Trip.where(from: 'Сочи', to: 'Тула').find_each do |trip|
        expect(response.body).to include?("Отправление: #{trip.start_time}")
        expect(response.body).to include?("Автобус: #{trip.bus.model} №#{trip.bus.number}")
      end
    end

    it 'renders index view' do
      expect(response).to render_template :index
    end
  end
end
