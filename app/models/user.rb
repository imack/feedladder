class User < TwitterAuth::GenericUser
  # Extend and define your user model as you see fit.
  # All of the authentication logic is handled by the 
  # parent TwitterAuth::GenericUser class.

  has_one :feed
  has_many :tweets,  :order => "created_at desc"

  key :shown_popup, Integer, :default => 0
end
