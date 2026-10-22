class Product < ApplicationRecord
  belongs_to :category
  has_many :reviews, dependent: :destroy
  ENERGY_CLASSES = %w[A B C D E F G].freeze
  WIDTHS = [45, 60].freeze

  enum :installation, { built_in: "built_in", freestanding: "freestanding" }

  validates :name, :brand, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :width_cm, inclusion: { in: WIDTHS }
  validates :energy_class, inclusion: { in: ENERGY_CLASSES }
  validates :capacity_sets, :programs_count,
            numericality: { only_integer: true, greater_than: 0 }
  validates :noise_db, numericality: { only_integer: true, in: 30..70 }
  validates :warranty_months, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def in_stock? = stock.to_i.positive?

  def to_param = "#{id}-#{name.parameterize}"
  
  def average_rating
  reviews.average(:rating)&.to_f&.round(1)
end

def reviews_count = reviews.count

end
