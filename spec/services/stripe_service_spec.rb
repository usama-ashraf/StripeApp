require 'rails_helper'

RSpec.describe StripeService do
  let(:valid_token) { 'tok_visa' }
  let(:invalid_token) { 'tok_invalid' }
  let(:valid_charge_id) { 'ch_123' }
  let(:invalid_charge_id) { 'ch_invalid' }

  before do
    Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
  end

  describe '#create_charge' do
    before do
      stub_request(:post, "https://api.stripe.com/v1/charges")
        .with(body: hash_including({source: valid_token}))
        .to_return(body: { id: valid_charge_id, object: 'charge', amount: 1000, currency: 'usd' }.to_json)

      stub_request(:post, "https://api.stripe.com/v1/charges")
        .with(body: hash_including({source: invalid_token}))
        .to_return(status: 400, body: { error: { message: 'Invalid source' } }.to_json)
    end

    it 'successfully creates a charge and saves it to the database' do
      service = StripeService.new
      expect {
        response = service.create_charge(10, 'usd')

        expect(response[:success]).to be true
        expect(response[:charge][:id]).to eq(valid_charge_id)
      }.to change(Charge, :count).by(1)

      charge = Charge.last
      expect(charge.stripe_charge_id).to eq(valid_charge_id)
      expect(charge.amount).to eq(10)
      expect(charge.currency).to eq('usd')
      expect(charge.status).to eq('success')
    end

  end

  describe '#refund_charge' do
    let!(:charge) { create(:charge, stripe_charge_id: valid_charge_id, amount: 1000, currency: 'usd', status: 'success', refunded: false) }

    before do
      stub_request(:post, "https://api.stripe.com/v1/refunds")
        .with(body: { charge: valid_charge_id })
        .to_return(body: { id: 're_123', object: 'refund', charge: valid_charge_id }.to_json)

      stub_request(:post, "https://api.stripe.com/v1/refunds")
        .with(body: { charge: invalid_charge_id })
        .to_return(status: 400, body: { error: { message: 'Invalid charge ID' } }.to_json)
    end

    it 'successfully refunds a charge and updates the database' do
      service = StripeService.new
      response = service.refund_charge(valid_charge_id)

      expect(response[:success]).to be true
      expect(response[:refund][:id]).to eq('re_123')

      charge.reload
      expect(charge.refunded).to be true
    end

    it 'handles failure when refunding a charge' do
      service = StripeService.new
      response = service.refund_charge(invalid_charge_id)

      expect(response[:success]).to be false
      expect(response).to have_key(:error)
    end
  end
end
