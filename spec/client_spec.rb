require 'spec_helper'

describe Withings::Client do

  let (:configured_client) do
    Withings::Client.new do |config|
      config.consumer_key = 'foo'
      config.consumer_secret = 'bar'
      config.token = 'secret'
      config.secret = 'super_secret'
    end
  end

  describe '#initialize' do
    context 'when an access token and secret are specified' do
      it 'should be connected' do
        client = Withings::Client.new({
          consumer_key: 'foo',
          consumer_secret: 'bar',
          token: 'token',
          secret: 'secret'
        })
        expect(client.connected?).to be true
      end
    end
    context 'when no access token or secret are specified' do
      describe '#consumer_key=' do
        it 'sets the consumer_key string' do
          subject.consumer_key = 'foo'
          expect(subject.consumer_key).to eq('foo')
        end
      end
      describe '#consumer_secret=' do
        it 'sets the consumer_secret string' do
          subject.consumer_secret = 'bar'
          expect(subject.consumer_secret).to eq('bar')
        end
      end
    end
  end
  
  describe '#user_agent' do
    it 'defaults to WithingsRubyGem/version' do
      expect(subject.user_agent).to eq("WithingsRubyGem/#{Withings::VERSION}")
    end
  end

  describe '#user_agent=' do
    it 'overwrites the User-Agent string' do
      subject.user_agent = 'MyWithingsClient/1.0.0'
      expect(subject.user_agent).to eq('MyWithingsClient/1.0.0')
    end
  end
  
  describe '#activities' do
    context 'when no consumer secret is provided' do
      it 'raises an error' do
        @client = Withings::Client.new({ consumer_key: 'foo' })
        expect { @client.activities(1234) }.to raise_error(Withings::Error::ClientConfigurationError)
      end
    end

    context 'when no consumer key is specified' do
      it 'raises an error' do
        @client = Withings::Client.new({ consumer_secret: 'foo' })
        expect { @client.activities(1234) }.to raise_error(Withings::Error::ClientConfigurationError)
      end
    end
    context 'when client is correctly configured' do
      before do
        stub_request(:get, /.*wbsapi.*/).
          with(query: hash_including({action: 'getactivity'})).
          to_return(body: '{"status":0,"body":{"activities":[{"date":"foo"}]}}')
      end

      let (:user_id) { 123 }
      let (:opts) { Hash['date', '2012-01-01'] }

      it 'should return an array of activities' do
        expect(configured_client.activities(user_id, opts)).to be_an Array
        expect(configured_client.activities(user_id, opts).first).to be_an Withings::Activity
      end
    end
  end

  context 'with an initialized client' do
    before do
      @client = Withings::Client.new do |config|
        config.consumer_key = 'foo'
        config.consumer_secret = 'bar'
      end
    end

    it 'has a consumer key' do
      expect(@client.consumer_key).not_to be nil
    end

    it 'has a consumer secret' do
      expect(@client.consumer_secret).not_to be nil
    end

  end
end
