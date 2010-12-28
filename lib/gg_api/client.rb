module GGApi
  class Client

    SITES = {
        :oauth      => 'https://auth.api.gg.pl/token',
        :authorize  => 'https://www.gg.pl/authorize'
      }

    SCOPES = {
        :pubdir     => 'https://pubdir.api.gg.pl',
        :users      => 'https://users.api.gg.pl',
        :life       => 'https://life.api.gg.pl'
      }

    attr_accessor :client_id, :client_secret, :code, :redirect_uri

    def client
      @client ||= OAuth2::Client.new(self.client_id, self.client_secret, {
        :authorize_url => SITES[:authorize],
        :access_token_url => SITES[:oauth]
      })
    end

    def initialize(client_id, client_secret, options = {})
      self.client_id = client_id
      self.client_secret = client_secret
      self.code = options[:code]
      self.redirect_uri = options[:redirect_uri]
    end

    def friends(whoam = 'me', attributes = {})
      path = "#{SCOPES[:users]}/friends/#{ whoam == 'me' ? whoam : "user," + whoam }"
      params = { :limit => 100 }.merge(attributes)
      access_token.get(path, params, {
          'Authorization' => "OAuth #{access_token.token}" ,
          'Expect' => '',
          'User-Agent' => "GGAPI-RUBY #{GGApi::VERSION}",
          'Accept-Charset' => 'ISO-8859-2,utf-8;q=0.7,*;q=0.7'
        })
    end

    def profile

    end

    def send_notification

    end

    def send_event

    end

    def avatar_url

    end

    def authorize_url(params)
      client.authorize_url({ :redirect_uri => self.redirect_uri, :response_type => 'code',
          :client_id => self.client_id }.merge(params))
    end

    def access_token?
      !access_token.nil?
    end

    def access_token
      @access_token ||= client.web_server.get_access_token(self.code,
          :redirect_uri => self.redirect_uri,
          :grant_type => 'authorization_code')
    end

  end
end

