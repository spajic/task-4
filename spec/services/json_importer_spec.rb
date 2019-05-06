require 'spec_helper'
describe 'Services::JsonImporter' do
  describe '#import_json_to_db', focus: true do
    it 'imports eight records of Trip into db' do
      expect { import_file }.to change(Trip, :count).by(8)
    end

    it 'has correct data' do
      import_file
      actual_result = Trip.first.to_h
      expected_result = {
        from: "Сочи",
        to: "Тула",
        start_time: "16:11",
        duration_minutes: 83,
        price_cents: 23354,
        bus: {
          number: "229",
          model: "Икарус",
          services: ["Ремни безопасности", "Кондиционер общий", "Кондиционер Индивидуальный", "Телевизор индивидуальный", "Стюардесса", "Можно не печатать билет"]
        }
      }
    end

    # expect(actual_result).to eq(expected_result)
  end

  def import_file
    JsonImporter.new().import_json_to_db(file_path: 'spec/fixtures/data.json')
  end
end
