# -*- coding: utf-8 -*-
class LogoutController < ApplicationController
  def index
    cookies.each do |k, v|
      # TODO 実際は消えてない!?
      cookies.delete(k)
    end
    redirect_to root_url
  end
end
