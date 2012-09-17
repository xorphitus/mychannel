class ApplicationController < ActionController::Base
  protect_from_forgery

  def hoge
    self.include?("Authentication")
  end
end
