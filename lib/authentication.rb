# -*- coding: utf-8 -*-

module Authentication
  AUTH_DURAITION_SEC = 60 * 60 * 24 * 7

  def auth_info_key
    cookies[:mychannel_token]
  end

  # before_filterで呼ぶと認証がかかる
  def require_authentication
    redirect_to root_url unless Rails.cache.read(auth_info_key)
  end

  def login
    fb_auth = FbGraph::Auth.new(Settings.fb.app_id, Settings.fb.app_secret)
    fb_auth.from_cookie(cookies)
    login_as(fb_auth.user.identifier, fb_auth.access_token.access_token)
  end

  def login_as fb_user_id, access_token
    expires_sec = Time.now + AUTH_DURAITION_SEC
    cookies[:mychannel_token] = {value: fb_user_id, expires: expires_sec}
    Rails.cache.write(fb_user_id, access_token, expires_in: expires_sec.to_i)
  end

  def logout
    Rails.cache.delete(auth_info_key)
    cookies[:mychannel_token] = {expires: Time.at(0)}
  end

  def authenticated?
    auth_info_key.present? && Rails.cache.read(auth_info_key).present?
  end

  # Facebookからログインユーザの情報を取得
  def fb_me
    begin
      FbGraph::User.me(Rails.cache.read(auth_info_key)).fetch
    rescue
      logout
      redirect_to root_url
    end
  end
end
