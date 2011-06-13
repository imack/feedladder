module HomeHelper

  def live_quote_explanation( live_quote )
    case live_quote
      when 0
        return "No longer active"
      when 1
        return "Active"
      when 2
        return "Retweeted by ProfQuotes!"
    end

  end

  def like_href_destination( feed )
    if feed[:facebook_page_url].nil? or feed[:facebook_page_url] == ""
      "#{feed.user.login}.feedladder.com/"
    else
      feed[:facebook_page_url]
    end
  end

  def header_logo
    if @current_feed && @current_feed.user.login == "profquotes"
      image_tag "pq_logo.png"
    else
      image_tag "fl_logo.png"
    end

  end

end
