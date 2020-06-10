# frozen_string_literal: true

require 'swagger_helper'

describe 'api/orders', type: :request do
  path '/api/orders' do
    get('list orders') do
      tags 'Order Tests'
      parameter name: 'X-Spree-Token', in: :header, type: :string

      response(200, 'successful') do
        let(:order) { create(:order_with_distributor) }
        let(:user) { order.distributor.owner }
        let(:'X-Spree-Token') do
          user.generate_spree_api_key!
          user.spree_api_key
        end

        run_test! do |response|
          expect(response).to have_http_status(200)

          data = JSON.parse(response.body)
          orders = data["orders"]
          expect(orders.size).to eq 1
          expect(orders.first["id"]).to eq order.id
        end
      end
    end
  end
end
