class StoriesController < ApplicationController
  include Authentication

  def emit
    render json: Story.get(get_fb_me)
  end
end
