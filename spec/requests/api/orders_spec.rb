require 'swagger_helper'

RSpec.describe 'api/orders', type: :request do
  path '/api/orders' do

    get('list orders') do
      tags 'Order Tests'
      security [{ api_key: [] }]

      response(200, 'successful') do
        let(:api_key) { 'some key' }
        
          before do |example|
            binding.pry
            submit_request(example.metadata)
          end
          
          it do
            binding.pry
            expect(response).to have_http_status(200)
          end
      end
    end
  end
end
