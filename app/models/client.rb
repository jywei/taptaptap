class Client
  attr_reader :response, :auth_token, :response_from_3taps, :response_by_token

  ADMINS = %w()

  def initialize(username, password, auth_token)
    @username = username
    @password = password
    @auth_token = auth_token

    @response_by_token = authenticate_by_token
    @response_from_3taps = authenticate_on_3taps
  end

  def authenticated?
    @response_by_token[:status] && @response_from_3taps
  end

  def is_admin?
    ADMINS.include?(auth_token)
  end

  private

  def authenticate_on_3taps
    begin
      url_get = "https://developer.3taps.com/login"
      url_post = "https://developer.3taps.com/session/"

      response = RestClient.get url_get
      body = Nokogiri.parse response.body
      token =  body.css('input[name=authenticity_token]').attr('value').value
      params = { "username"=> @username, "password" => @password, "authenticity_token" => token }

      res = RestClient.post url_post, params, { "cookies" => response.cookies }
      res.size > 100 ? false : true
    rescue Exception => e
      e.respond_to?(:message) && e.message == "302 Found"
    end
  end

  def authenticate_by_token
    url = accounts_service_url(@auth_token)
    uri = URI.parse(url)

    begin
      response = Net::HTTP.get_response(uri);

      res = { details: Hash.from_xml(response.body) }
      res[:status] = (response.code == "200") ? true : false

      res
    rescue Exception => e
      { status: false, details: "Connection error" }
    end
  end

  protected

  def accounts_service_url(auth_token)
    raise "Accounts service URL is not set"
  end
end