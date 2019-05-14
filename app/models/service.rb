class Service < ApplicationRecord
  SERVICES = [
    'WiFi',
    'Туалет',
    'Работающий туалет',
    'Ремни безопасности',
    'Кондиционер общий',
    'Кондиционер Индивидуальный',
    'Телевизор общий',
    'Телевизор индивидуальный',
    'Стюардесса',
    'Можно не печатать билет',
  ].freeze

  # has_and_belongs_to_many :buses, join_table: :buses_services
  has_many :buses_services, class_name: 'BusesService'
  has_many :buses, through: :buses_services

  validates :name, presence: true
  validates :name, inclusion: { in: SERVICES }
end
