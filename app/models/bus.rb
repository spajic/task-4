class Bus < ApplicationRecord
  MODELS = [
    'Икарус',
    'Мерседес',
    'Сканиа',
    'Буханка',
    'УАЗ',
    'Спринтер',
    'ГАЗ',
    'ПАЗ',
    'Вольво',
    'Газель',
  ].freeze

  has_many :trips, dependent: :destroy
  # has_and_belongs_to_many :services, join_table: :buses_services
  has_many :buses_services, class_name: 'BusesService'
  has_many :services, through: :buses_services

  validates :number, presence: true, uniqueness: true
  validates :model, inclusion: { in: MODELS }
end
