require 'httparty'
require 'json'

module MollieApi
  class Client
    include HTTParty
    base_uri "https://api.mollie.com"
    format :json
    attr_accessor :api_key, :api_version

    def initialize(api_key, api_version = 'v1')
      self.api_key = api_key
      self.api_version = api_version
    end

    def auth_token
      "Bearer " + self.api_key
    end

    def prepare_payment(amount, description, redirect_url, metadata = {}, method=nil, method_params = {})
      response = self.class.post("/#{self.api_version}/payments",
        :body => {
          :amount => amount,
          :description => description,
          :redirectUrl => redirect_url,
          :metadata => metadata,
          :method => method
        }.merge(method_params),
        :headers => {
          'Authorization' => auth_token
        }
      )
      JSON.parse(response.body)
    end

    def issuers
      response = self.class.get("/#{self.api_version}/issuers",
        :headers => {
          'Authorization' => auth_token
        }
      )
      response = JSON.parse(response.body)
      response["data"].map {|issuer| {id: issuer["id"], name: issuer["name"]} }
    end

    def payment_status(payment_id)
      response = self.class.get("/#{self.api_version}/payments/#{payment_id}",
        :headers => {
          'Authorization' => auth_token
        }
      )
      JSON.parse(response.body)
    end

    def refund_payment(payment_id)
      response = self.class.post("/#{self.api_version}/payments/#{payment_id}/refunds",
        :headers => {
          'Authorization' => auth_token
        }
      )
      JSON.parse(response.body)
    end

    def payment_methods(method = nil)
      if method
        url = "/#{self.api_version}/methods/#{method}"
      else
        url = "/#{self.api_version}/methods"
      end

      response = self.class.get(url,
        :headers => {
          'Authorization' => auth_token
        }
      )
      JSON.parse(response.body)
    end

  end
end
