require 'spec_helper'

describe GGApi::Client do
  
  let(:client) do
    cli = GGApi::Client.new('id', 'secret', :code => 'code', :redirect_uri => 'http://localhost')
    cli.client.connection.build do |b|
      b.adapter :test do |stub|
        stub.post('/token') { |env| [200, {'Content-Type' => 'application/json'}, "{ 'access_token': 'abc', 'refresh_token': 'def' }"] }
        stub.get('/friends/me?limit=100') { |env| [200, {'Content-Type' => 'application/json'}, "{ 'result': { 'users': [ { 'id': '2080', 'type': 'user', 'label': 'Jurek', 'name': 'Jerzy', 'birth': '1980-04-17T00:00:00+02:00', 'gender': '2', 'city': 'Warszawa' }] } }"] }
        stub.get('/users/me') { |env| [200, { 'Content-Type' => 'application/json'}, "{ 'result': { 'users': [ { 'id': '2080', 'type': 'user', 'label': 'Jurek', 'name': 'Jerzy', 'birth': '1980-04-17T00:00:00+02:00', 'gender': '2', 'city': 'Warszawa' }] } }"] }
        stub.post('/event') { |env| [200, {}, ""] }
        stub.post('/notification') { |env| [200, {}, ""] }
      end
    end
    cli
  end

  describe '#initialize' do
    it 'should correct assign client_id and client_secret' do
      client.client_id.should == 'id'
      client.client_secret.should == 'secret'
      client.code.should == 'code'
      client.redirect_uri.should == 'http://localhost'
    end
  end

  describe '#authorize_url' do
    it 'should make correct url with default code and redirect_uri' do
      client.authorize_url(:scope => 'life pubdir').should == 'https://www.gg.pl/authorize?scope=life%20pubdir&response_type=code&client_id=id&redirect_uri=http%3A%2F%2Flocalhost'
    end

    it 'should make correct url with passed code and redirect_uri' do
      client.authorize_url(:scope => 'life pubdir', :redirect_uri => 'http://localhost2').should == 'https://www.gg.pl/authorize?scope=life%20pubdir&response_type=code&client_id=id&redirect_uri=http%3A%2F%2Flocalhost2'
    end
  end

  describe '#requesting' do

    it 'friends' do
      friends = client.friends
      friends.should be_kind_of(Array)
      friends.each do |friend|
        friend.should be_kind_of(GGApi::GGObject)
      end

    end

    it 'profile' do
      client.profile.should be_kind_of(GGApi::GGObject)
    end

    it 'send_notification' do
      client.send_notification :message => 'test'
    end

    it 'send_event' do
      client.send_event :message => 'test'
    end

  end

  describe '#avatar_url' do
    it 'should make url without params' do
      client.avatar_url(123).should == "#{GGApi::Client::GG_AVATARS_URL}/123"
    end

    it 'should make url with default=mini param' do
      client.avatar_url(123, :default => 'mini').should == "#{GGApi::Client::GG_AVATARS_URL}/123?default=mini"
    end

    it 'should make url with two params' do
      client.avatar_url(123, :default => 'mini', :format => 'jpeg').should == "#{GGApi::Client::GG_AVATARS_URL}/123?format=jpeg&default=mini"
    end
  end

  describe '#access_token?' do
    it 'should return true' do
      client.access_token = 'ajdshdasd'
      client.access_token?.should == true
    end

    it 'should return false' do
      client.access_token = nil
      client.access_token?.should == false
    end

  end
  
end
