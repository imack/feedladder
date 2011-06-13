
require 'test_helper'
require 'rubygems'
require 'notifo'

class NotifoTest < ActionController::IntegrationTest


  test "Send an update to Notifo" do
    notifo = Notifo.new("imack","x52e1bf2929ffbf4d3ac8bb515a26d4bc06d1e8e5")
    notifo.post("imack","LaughLitmus Test Message")
  end

end

