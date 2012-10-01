# -*- coding: utf-8 -*-
class LogoutController < ApplicationController
  include Authentication

  def index
    redirect_to "https://www.facebook.com/logout.php?next=#{root_url}&access_token=#{@access_token}"
  end
end
