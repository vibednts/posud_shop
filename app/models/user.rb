class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  validates :name, presence: true, length: { maximum: 80 }
  validates :phone, format: { with: /\A\+?\d[\d\s\-()]{8,17}\z/, message: "має неправильний формат" }, allow_blank: true
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
