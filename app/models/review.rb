class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :rating, inclusion: { in: 1..5, message: "має бути від 1 до 5" }
  validates :body, presence: true, length: { minimum: 5, maximum: 1000 }
  validates :user_id, uniqueness: { scope: :product_id, message: "вже залишив відгук на цей товар" }
end
