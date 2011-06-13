require 'test_helper'
require 'fakeweb'

class TweetControllerTest < ActionController::TestCase

  include ActionView::Helpers::TweetHelper

  test "Twitter down should cause render of system_down" do
    @request.session[:current_user] = User.new()
    FakeWeb.register_uri(:get, %r|http://twitter\.com/|, :body => "NOT API COMPLIANT")
    get :nominate
    assert_template "errors/system_down"
  end
  
  test "Bitly properly shortens url" do
    shortened = get_bitly_url( "http://laughlitm.us" )
    puts shortened
    assert shortened = "http://bit.ly/a1WZ7e"
  end

end
