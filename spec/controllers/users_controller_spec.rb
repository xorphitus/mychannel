require 'spec_helper'

describe UsersController do

  before(:each) do
    class FbUserMock
      def user_id
        1
      end
    end

    module Authentication
      def require_authentication
      end
      def get_fb_me
        FbUserMock.new
      end
    end
  end

  describe "POST create" do
    it "redirects to channels" do
      post 'create'
      response.should redirect_to(:channels)
    end
  end

  describe "PUT 'update'" do
    it "redirects to channels" do
      put 'update', {id: 1}
      response.should redirect_to(:channels)
    end
  end
end
