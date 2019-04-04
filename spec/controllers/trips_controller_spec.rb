describe TripsController do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  render_views

  describe '#index' do
    subject { get URI.escape('/автобусы/Самара/Москва') }

    before do
      DbPopulator.populate('fixtures/example.json')
    end

    it do
      subject
      expect(last_response.status).to eq 200
      expect(last_response.body).to include 'В расписании 5 рейсов'
      expect(last_response.body).to include '<li>Автобус: Икарус №123</li>'
    end
  end
end
