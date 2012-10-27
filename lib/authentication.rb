# -*- coding: utf-8 -*-

module Authentication
  # before_filterで呼ぶと認証がかかる
  def require_authentication
    redirect_to new_session_url if session[:access_token].blank?
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
end
