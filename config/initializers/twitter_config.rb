TWITTER_CONFIG = YAML.load_file("#{::Rails.root.to_s}/config/twitter_auth.yml")[::Rails.env]

require 'json'
require 'twitter_auth'

::Rails.logger.info("** TwitterAuth initialized properly.")