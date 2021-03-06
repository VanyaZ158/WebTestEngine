require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WebTestEngine
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.time_zone = ENV['TIME_ZONE'] || raise('TIME_ZONE env is not set')

    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('lib', 'services')

    config.available_locales = %i[en ru]
    config.default_locale = :en

    config.x = Hashie::Mash.new(Rails.application.config_for(:settings))

    config.cache_store = :redis_store, "#{config.x.global_info.redis.connection_url}/cache", { expires_in: 90.minutes }
    config.session_store :cookie_store, expire_after: 14.days

    config.active_job.queue_adapter = :sidekiq

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: %i[get post put options]
      end
    end
  end
end
