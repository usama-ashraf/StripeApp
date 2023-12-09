# spec/factories/charges.rb
FactoryBot.define do
  factory :charge do
    stripe_charge_id { "ch_#{Faker::Number.number(digits: 10)}" }
    amount { 1000 }
    currency { 'usd' }
    status { 'pending' }
    refunded { false }
  end
end
