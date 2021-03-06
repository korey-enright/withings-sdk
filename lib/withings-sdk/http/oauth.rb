require 'oauth'

module WithingsSDK
  module HTTP
    module OAuthClient
      attr_accessor :consumer_key, :consumer_secret, :token, :secret
      attr_writer :consumer

      DEFAULT_OPTIONS = {
        site:              'https://oauth.withings.com',
        proxy:              nil,
        request_token_path: '/account/request_token',
        authorize_path:     '/account/authorize',
        access_token_path:  '/account/access_token',
        scheme:             :query_string
      }

      def request_token(options = {})
        consumer.get_request_token(options)
      end

      def authorize_url(token, secret, options = {})
        request_token = OAuth::RequestToken.new(consumer, token, secret)
        request_token.authorize_url(options)
      end

      def access_token(token, secret, options = {})
        request_token = OAuth::RequestToken.new(consumer, token, secret)
        @access_token = request_token.get_access_token(options)
        @token = @access_token.token
        @secret = @access_token.secret
        @access_token
      end

      def existing_access_token(token, secret)
        OAuth::AccessToken.new(consumer, token, secret)
      end

      def connected?
        !@access_token.nil?
      end

      private

      def consumer
        @consumer ||= OAuth::Consumer.new(@consumer_key, @consumer_secret, DEFAULT_OPTIONS)
      end
    end
  end
end
