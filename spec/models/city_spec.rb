require 'rails_helper'

describe City do
  describe '.create' do
    subject(:create) do
      City.create(name: 'Bolhov')
    rescue
      nil
    end

    it "doesn't sends request to check uniqueness of name" do
      expect { create }.not_to exceed_query_limit(0).with(/^SELECT/)
    end

    it "doesn't create bus with existed name" do
      City.create(name: 'Bolhov')
      expect { create }.not_to change(City, :count)
    end
  end
end
