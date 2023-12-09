require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  describe 'POST #stripe' do
    before do
      allow(Stripe::Webhook).to receive(:construct_event) do |raw_post, signature, secret|
        event_data = JSON.parse(raw_post, symbolize_names: true)
        OpenStruct.new({
                         type: event_data[:type],
                         data: OpenStruct.new({
                                                object: OpenStruct.new(event_data[:data][:object])
                                              })
                       })
      end
    end

    let(:charge_succeeded_event) {
      {
        id: 'evt_1',
        type: 'charge.succeeded',
        data: {
          object: {
            id: 'ch_123',
            object: 'charge',
            amount: 1000,
            currency: 'usd'
          }
        }
      }.to_json
    }

    let(:charge_refunded_event) {
      {
        id: 'evt_2',
        type: 'charge.refunded',
        data: {
          object: {
            id: 'ch_123',
            object: 'charge'
          }
        }
      }.to_json
    }

    let!(:charge) { create(:charge, stripe_charge_id: 'ch_123', amount: 1000, currency: 'usd', status: 'pending', refunded: false) }

    it 'updates charge status on charge.succeeded event' do
      post :stripe, body: charge_succeeded_event, as: :json

      expect(response).to have_http_status(:ok)
      charge.reload
      expect(charge.status).to eq('succeeded')
    end

    it 'updates charge as refunded on charge.refunded event' do
      post :stripe, body: charge_refunded_event, as: :json

      expect(response).to have_http_status(:ok)
      charge.reload
      expect(charge.refunded).to be true
    end
  end
end
