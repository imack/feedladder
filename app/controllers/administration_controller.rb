class AdministrationController < ApplicationController
  before_filter :authorize

  def authorize
    if not admin_user?
      logger.warn("SECURITY - Unauthorized access attempt")
      redirect_to "/"
    end
  end

  def index
    @user_count = User.count
    @total_quote_count = Tweet.count()
    @live_quote_count = Tweet.count( :conditions => "live_quote = 1" )
    @total_vote_count = 0 #Tweet.sum(:random_wins)
    @last_10_quotes = Tweet.all( :order=>'created_at DESC', :limit=>10 )

  end

  def redlight
    @quote = Tweet.find(params[:id])
    @quote.live_quote = 0
    @quote.save

    redirect_to :action=> "index"

  end


  def greenlight
    @quote = Tweet.find(params[:id])
    @quote.live_quote = 2
    @quote.save

    redirect_to :action=>"index"
    
  end

end
