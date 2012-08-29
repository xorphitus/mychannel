require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  test "should get emit" do
    get :emit
    assert_response :success
  end

end
