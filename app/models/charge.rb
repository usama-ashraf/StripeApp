class Charge < ApplicationRecord
  validates :stripe_charge_id, presence: true, uniqueness: true
  validates :amount, numericality: { greater_than: 0 }
  validates :currency, presence: true
end
