require 'stripe'

class StripeService
  def initialize
    Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
  end

  def create_charge(amount, currency)
    begin
      charge = Stripe::Charge.create(
        source: 'tok_visa',
        amount: amount * 100,  # Convert dollars to cents
        currency: currency,
        description: "This is a test charge"
      )
      Charge.create!(stripe_charge_id: charge.id, amount: amount, currency: currency, refunded: false, status: 'success')
      { success: true, charge: charge }
    rescue Stripe::StripeError => e
      { success: false, error: e.message }
    rescue StandardError => e
      { success: false, error: "An unexpected error occurred: #{e.message}" }
    end
  end

  def refund_charge(charge_id)
    begin
      refund = Stripe::Refund.create(charge: charge_id)
      charge_record = Charge.find_by(stripe_charge_id: charge_id)
      charge_record.update(refunded: true) if charge_record
      { success: true, refund: refund }
    rescue Stripe::StripeError => e
      { success: false, error: e.message }
    rescue StandardError => e
      { success: false, error: "An unexpected error occurred: #{e.message}" }
    end
  end
end
