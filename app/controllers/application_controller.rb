# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :fb_me

  AUTH_DURAITION_SEC = 60 * 60
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
      reset_session
      redirect_to new_session_url
    end
  end

  private
  # before_filterで呼ぶと認証がかかる
  def require_authentication
    redirect_to new_session_url unless authenticated?
  end

  def authenticated?
    session[:access_token].present?
  end
end
