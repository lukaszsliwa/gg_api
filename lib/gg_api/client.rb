require 'oauth2'
require 'json'

module GGApi
  class Client

    GG_FRIENDS_URL      = 'https://users.api.gg.pl/friends'
    GG_USERS_URL        = 'https://pubdir.api.gg.pl/users'
    GG_NOTIFICATION_URL = 'https://life.api.gg.pl/notification'
    GG_EVENT_URL        = 'https://life.api.gg.pl/event'

    GG_OAUTH_URL        = 'https://auth.api.gg.pl/token'
    GG_AUTHORIZE_URL    = 'https://www.gg.pl/authorize'

    GG_AVATARS_URL      = 'http://avatars.gg.pl'

    attr_accessor :client_id, :client_secret, :code, :redirect_uri

    def client
      @client ||= OAuth2::Client.new(self.client_id, self.client_secret,
        :authorize_url => GG_AUTHORIZE_URL,
        :access_token_url => GG_OAUTH_URL,
        :parse_json => true)
    end

    def initialize(client_id, client_secret, options = {})
      self.client_id = client_id
      self.client_secret = client_secret
      self.code = options[:code]
      self.redirect_uri = options[:redirect_uri]
    end

    def friends(user = nil, attributes = {})
      hash = request(:get, "#{GG_FRIENDS_URL}/#{ whoam user }", { :limit => 100 }.merge(attributes), header)
      result = []
      if hash.kind_of?(Hash) && hash['result']
        hash['result']['friends'].each do |friend|
          result << GGObject.new(friend)
        end
      end
      result
    end

    def profile(user = nil)
      hash = request(:get, "#{GG_USERS_URL}/#{ whoam user }", {}, header)
      users = hash.kind_of?(Hash) && hash['result'] ? hash['result']['users'] : []
      users.kind_of?(Array) ? GGObject.new(users[0]) : nil
    end

    def send_notification(params)
      request(:post, GG_NOTIFICATION_URL, { :to => 'friends' }.merge(params), header);
    end

    def send_event(params)
        request(:post, GG_EVENT_URL, params, header);
    end

    def avatar_url(user, default = nil)
      "#{GG_AVATARS_URL}/#{user}#{default ? '?default=' + default.to_s : ''}";
    end

    def authorize_url(params)
      client.authorize_url({ :redirect_uri => self.redirect_uri, :response_type => 'code',
          :client_id => self.client_id }.merge(params))
    end

    def access_token?
      !@access_token.nil?
    end

    def access_token(code = nil)
      unless @access_token
        code ||= self.code
        request = request(:post, GG_OAUTH_URL,
          :code => code,
          :redirect_uri => redirect_uri,
          :client_id => client_id,
          :client_secret => client_secret,
          :grant_type => 'authorization_code')
        @access_token =  OAuth2::AccessToken.new(client, request['access_token'], request['refresh_token'])
      end
      @access_token
    end

    private

    def refresh_token
      raise GGApiException.new('require access_token') unless @access_token
      request = request(:post, GG_OAUTH_URL,
            :refresh_token => @access_token.refresh_token,
            :grant_type => 'refresh_token',
            :client_id => client_id,
            :client_secret => client_secret,
            :redirect_uri => redirect_uri)
      @access_token = OAuth2::AccessToken.new(client, request['access_token'], request['refresh_token'])
    end

    def whoam(user = nil)
      user.nil? ? 'me' : "user," + user.to_s
    end

    def request(verb, path, params = {}, headers = {})
      begin
        raw_request(verb, path, params, headers)
      rescue OAuth2::HTTPError => err
        exc = GGApiException.from(err)
        if exc.kind_of?(GGApiUnauthorizedException)
          refresh_token
          begin
            raw_request(verb, path, params, headers)
          rescue OAuth2::HTTPError => err
            raise GGApiException.from(err)
          end
        else
          raise exc
        end
      end
    end

    def raw_request(verb, path, params = {}, headers = {})
      client.request(verb, path, params, {
        'User-Agent' => "GGAPI-RUBY #{GGApi::VERSION}",
        'Except' => '',
        'Accept-Charset' => 'ISO-8859-2,utf-8;q=0.7,*;q=0.7',
        'content_type' => 'application/json' }.merge(headers))
    end

    def header
      { 'Authorization' => "OAuth #{access_token.token}" }
    end

  end
end

