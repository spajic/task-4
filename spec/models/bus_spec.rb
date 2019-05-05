require 'rails_helper'

describe Bus do
  describe '.create' do
    subject(:create) do
      Bus.create(model: Bus::MODELS.first, number: 1)
    rescue
      nil
    end

    it "doesn't sends request to check uniqueness of name" do
      expect { create }.not_to exceed_query_limit(0).with(/^SELECT/)
    end

    it "doesn't create bus with existed number" do
      Bus.create(model: Bus::MODELS.last, number: 1)
      expect { create }.not_to change(Bus, :count)
    end
  end
end
