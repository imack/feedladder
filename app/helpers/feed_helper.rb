module FeedHelper

  def light_status_show( quote )
    status_html = "<span class='status_indicators'>"

    if quote.traffic_light == 0
      status_html += "<span class='status_indicator initial_lit red_indicator red_on' onclick=''></span>"
    else
      status_html += "<span class='status_indicator red_indicator red_off' onclick=''></span>"
    end

    if quote.traffic_light == 1
      status_html += "<span class='status_indicator initial_lit yellow_indicator yellow_on' onclick=''></span>"
    else
      status_html += "<span class='status_indicator yellow_indicator yellow_off' onclick=''></span>"
    end

    if quote.traffic_light == 2
      status_html += "<span class='status_indicator initial_lit green_indicator green_on' onclick=''></span>"
    else
      status_html += "<span class='status_indicator green_indicator green_off' onclick=''></span>"
    end
    status_html += "</span>"

    return status_html
  end

  def tweet_now_button(tweet)
    return unless @current_feed.is_admin( current_user )
    return unless tweet.live_quote != 2
    
    status_html = "<span class='tweet_now'>"
    status_html += link_to "Tweet Now", :controller=>"tweet", :action=>"tweet_now", :id=>tweet.id
    return status_html + "</span>"
  end

end
