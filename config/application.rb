require_relative 'boot'

require 'rails/all'
require 'bittrex'



# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GoldenEggsHen
  class Application < Rails::Application

    Bittrex.config do |c|
      c.key = ENV["BITTREX_API_KEY"]
      c.secret = ENV["BITTREX_API_SECRET"]
    end
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
