class HomeController < ApplicationController

  before_filter :assert_login, :only => :profile

  def index
    
  end

  def profile
    @user = current_user
    @quotes = @user.tweets[0..19]
    redirect_to "/" unless !@user.nil?
  end

  def signup
    session['signup_catch'] = true
    if @next.nil?
      @next = "/"
    end
  end

  def about_us
  end

  def privacy_policy
  end

  def terms_of_service
  end

  def contact_us
  end

end
