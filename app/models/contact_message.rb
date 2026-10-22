class ContactMessage < ApplicationRecord
  validates :name, presence: true, length: { maximum: 80 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, presence: true, length: { maximum: 120 }
  validates :body, presence: true, length: { minimum: 10, maximum: 2000 }
end
