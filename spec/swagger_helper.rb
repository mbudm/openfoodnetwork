# frozen_string_literal: true

require 'spec_helper'

RSpec.configure do |config|
  config.swagger_root = Rails.root.join('swagger').to_s
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      components: {
        securitySchemes: {
          api_key: {
              type: :apiKey,
              name: 'api_key',
              in: :query
          }
        }
      },
      paths: {},
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: '0.0.0.0:3000/'
            }
          }
        }
      ]
    }
  }
  config.swagger_format = :yaml
end
