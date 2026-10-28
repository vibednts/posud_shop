class Product < ApplicationRecord
  belongs_to :category
  has_many :order_items, dependent: :restrict_with_error
has_many :cart_items, dependent: :destroy
has_one_attached :image
  has_many :reviews, dependent: :destroy
  ENERGY_CLASSES = %w[A B C D E F G].freeze
  WIDTHS = [ 45, 60 ].freeze

enum :installation, { built_in: "built_in", freestanding: "freestanding" }, validate: true

INSTALLATION_LABELS = { "built_in" => "Вбудована", "freestanding" => "Окремостояча" }.freeze

  validates :name, :brand, presence: true
  validates :price, numericality: { greater_than: 0 }
  validate :acceptable_image
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

private

def acceptable_image
  return unless image.attached?

  errors.add(:image, "має бути у форматі JPG, PNG або WebP") unless image.content_type.in?(%w[image/jpeg image/png image/webp])
  errors.add(:image, "має бути не більше 5 МБ") if image.byte_size > 5.megabytes
end
end
