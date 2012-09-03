module Authentication

  class UnauthorizedError < StandardError; end

  def self.included(base)
    base.before_filter :require_authentication
  end

  def require_authentication
    fb_auth = FbGraph::Auth.new(Settings.fb.app_id, Settings.fb.app_secret)
    begin
      fb_auth.from_cookie(cookies)
      @access_token = fb_auth.access_token
    rescue
      redirect_to root_url
    end
  end

end
