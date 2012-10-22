# -*- coding: utf-8 -*-

module Authentication
  AUTH_DURAITION_SEC = 60 * 60

  # before_filterで呼ぶと認証がかかる
  def require_authentication
    redirect_to root_url if session[:access_token].blank?
  end

  def login
    fb_auth = FbGraph::Auth.new(Settings.fb.app_id, Settings.fb.app_secret)
    fb_auth.from_cookie(cookies)
    login_as(fb_auth.user.identifier, fb_auth.access_token.access_token)
  end

  def login_as fb_user_id, access_token
    session[:fb_user_id] = fb_user_id
    session[:access_token] = access_token
  end

  def logout
    reset_session
  end

  def authenticated?
    session[:access_token].present?
  end

  # Facebookからログインユーザの情報を取得
  def fb_me
    fb_user_id = session[:fb_user_id]
    if fb_user_id.present?
      me = Rails.cache.read(fb_user_id)
      return me if me.present?
    end

    begin
      me = FbGraph::User.me(session[:access_token]).fetch
      fb_user_id = session[:fb_user_id] = me.identifier
      expires_sec = Time.now + AUTH_DURAITION_SEC
      Rails.cache.write(fb_user_id, me, expires_in: expires_sec.to_i)
      me
    rescue
      logout
      redirect_to root_url
    end
  end
end
