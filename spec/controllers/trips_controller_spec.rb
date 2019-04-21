# frozen_string_literal: true

require 'rails_helper'

describe TripsController do
  describe 'GET index' do
    let_it_be(:moscow) { create(:city, name: 'Москва') }
    let_it_be(:samara) { create(:city, name: 'Самара') }

    context 'N+1', :n_plus_one do
      populate { |n| create_list(:trip, n) }

      specify do
        expect { get :index, params: { from: moscow.name, to: samara.name } }
          .to perform_constant_number_of_queries
      end
    end
  end
end
