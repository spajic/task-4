# frozen_string_literal: true

FactoryBot.define do
  factory :trip do
    from
    to
    bus
    duration_minutes { 200 }
    start_time { '11:45' }
    price_cents { 100 }
  end

  factory :city, aliases: %i[to from] do
    name { Faker::Address.city.tr(' ', '_') }
  end

  factory :bus do
    number { Faker::Number.number(5) }
    model { Bus::MODELS[rand(0..9)] }

    after(:create) do |bus, _evaluator|
      create_list(:buses_service, 5, bus: bus)
    end
  end

  factory :service do
    name { Service::SERVICES[rand(0..9)] }
  end

  factory :buses_service do
    bus
    service
  end
end
