class WebhooksController < ApplicationController
  # skip_before_action :verify_authenticity_token if Rails.env.test?

  def stripe
    event = Stripe::Webhook.construct_event(
      request.body.read,
      request.env['HTTP_STRIPE_SIGNATURE'],
      Rails.application.credentials.stripe[:webhook_secret]
    )

    case event.type
    when 'charge.succeeded'
      update_charge_status(event.data.object.id, 'succeeded')
    when 'charge.refunded'
      update_charge_refunded(event.data.object.id)
    end

    render json: { message: 'Handled Stripe webhook' }, status: :ok
  rescue Stripe::SignatureVerificationError, Stripe::StripeError => e
    render json: { error: e.message }, status: :bad_request
  end

  private

  def update_charge_status(stripe_charge_id, status)
    charge = Charge.find_by(stripe_charge_id: stripe_charge_id)
    charge.update(status: status) if charge
  end

  def update_charge_refunded(stripe_charge_id)
    charge = Charge.find_by(stripe_charge_id: stripe_charge_id)
    charge.update(refunded: true, refunded_at: DateTime.now) if charge
  end
end
