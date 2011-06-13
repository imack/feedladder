require 'subdomain'

Profquotes::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  
  match '/tweet/submit' => 'tweet#submit', :as => "submit"
  match '/tweet/submit_retweet' => 'tweet#submit_retweet', :as => "submit_retweet"
  match '/tweet/disable' => 'tweet#disable', :as => "disable"
  match '/tweet/vote' => 'tweet#vote', :as => "vote"
  match '/tweet/change_status' => 'tweet#change_status', :as => "change_status"
  match '/tweet/ask_to_tweet' => 'tweet#ask_to_tweet', :as => "ask_to_tweet"
  match '/tweet/more_tweets' => 'tweet#more_tweets'
    
  match '/signup' => "home#signup", :as => "signup"

  match '/t/:id' => "tweet#show", :as => "show"


  match '/login' => 'sessions#new', :as => "login"
  match '/logout' => 'sessions#destroy', :as => "logout"
  match '/oauth_callback' => 'sessions#oauth_callback', :as => "oauth_callback"

  resources :tweet, :feed, :session

  constraints(Subdomain) do
    match 'more_tweets' => "feed#more_tweets"
    match '/' => "feed#show", :as => :feed_root
    match 'edit' => "feed#edit", :as => :edit_feed
  end

  
  match '/:controller(/:action(/:id))'
  root :to => "home#index"
end
