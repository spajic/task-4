describe DbPopulator do
  describe '.populate' do
    subject { described_class.populate(file_name) }

    let(:file_name) { 'spec/fixtures/micro.json' }

    it do
      expect { subject }.to change { City.count }.by(5)
        .and change { Bus.count }.by(3)
        .and change { Service.count }.by(8)
        .and change { Trip.count }.by(3)

      expect(City.pluck(:name).sort).to eq %w(Волгоград Красноярск Самара Сочи Тула)
      expect(Bus.pluck(:number).sort).to eq %w(229 584 912)

      expect(Service.pluck(:name).sort).to eq [
        "WiFi",
        "Кондиционер Индивидуальный",
        "Кондиционер общий",
        "Можно не печатать билет",
        "Работающий туалет",
        "Ремни безопасности",
        "Стюардесса",
        "Телевизор индивидуальный",
      ]

      expect(Trip.pluck(:price_cents).sort).to eq [23354, 80288, 83861]
    end
  end
end
