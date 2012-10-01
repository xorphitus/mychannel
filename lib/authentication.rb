# -*- coding: utf-8 -*-

# controllerでincludeするとFacebookログインしないとアクセスできないリソースになる
module Authentication
  def self.included base
    base.before_filter :require_authentication
  end

  def require_authentication
    fb_auth = FbGraph::Auth.new(Settings.fb.app_id, Settings.fb.app_secret)
    begin
      fb_auth.from_cookie cookies
      @access_token = fb_auth.access_token
    rescue
      redirect_to root_url
    end
  end

  # Facebookからログインユーザの情報を取得
  def get_fb_me
    FbGraphExtension::User.me(@access_token).fetch
  end
end
