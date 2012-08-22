require 'test_helper'

class StoriesControllerTest < ActionController::TestCase
  test "should get emit" do
    get :emit
    assert_response :success
  end

end
