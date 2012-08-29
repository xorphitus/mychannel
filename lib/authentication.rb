APP_ID = '277546059018319'
APP_SECRET = 'be011e651b72d05be21249473ff94185'

module Authentication

  class UnauthorizedError < StandardError; end

  def self.included(base)
    base.before_filter :require_authentication
  end

  def require_authentication
    fb_auth = FbGraph::Auth.new(APP_ID, APP_SECRET)
    begin
      fb_auth.from_cookie(cookies)
      @access_token = fb_auth.access_token
    rescue
      redirect_to root_url
    end
  end

end
