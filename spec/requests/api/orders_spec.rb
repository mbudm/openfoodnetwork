# frozen_string_literal: true

require 'swagger_helper'

describe 'api/orders', type: :request do
  path '/api/orders' do
    get('list orders') do
      tags 'Orders'
      parameter name: 'X-Spree-Token', in: :header, type: :string
      parameter name: 'q[distributor_id_eq]', in: :query, type: :string, required: false, description: "Query orders for a specific distributor id."
      parameter name: 'q[completed_at_gt]', in: :query, type: :string, required: false, description: "Query orders completed after a date."
      parameter name: 'q[completed_at_lt]', in: :query, type: :string, required: false, description: "Query orders completed before a date."
      parameter name: 'q[state_eq]', in: :query, type: :string, required: false, description: "Query orders by order state, eg 'cart', 'complete'."
      parameter name: 'q[payment_state_eq]', in: :query, type: :string, required: false, description: "Query orders by order payment_state, eg 'balance_due', 'paid', 'failed'."
      parameter name: 'q[email_cont]', in: :query, type: :string, required: false, description: "Query orders where the order email contains a string."
      parameter name: 'q[order_cycle_id_eq]', in: :query, type: :string, required: false, description: "Query orders for a specific order_cycle id."
      
      response(200, 'get orders') do
        # Adds model metadata for Swagger UI. Ideally we'd be able to just add:
        # schema '$ref' => '#/components/schemas/Order_Concise'
        # Which would also validate the response in the test, however this is an open 
        # issue with rswag: https://github.com/rswag/rswag/issues/268
        metadata[:response][:content] = { "application/json": {
            schema: {'$ref' => '#/components/schemas/Order_Concise'}
          }
        }
        
        let(:order_1) { create(:order_with_distributor) }
        let(:order_2) { create(:order_with_distributor) }
        let(:user) { order_1.distributor.owner }
        let(:'X-Spree-Token') do
          user.generate_spree_api_key!
          user.spree_api_key
        end
        let(:'q[distributor_id_eq]') { order_1.distributor.id }

        run_test! do |response|
          expect(response).to have_http_status(200)

          data = JSON.parse(response.body)
          orders = data["orders"]
          expect(orders.size).to eq 1
          expect(orders.first["id"]).to eq order_1.id
        end
      end
    end
  end
end
