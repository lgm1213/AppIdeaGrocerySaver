require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AppIdeaGrocerySaver
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # All tables use UUID primary keys (PostgreSQL pgcrypto extension)
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    # Route ActiveJob through Solid Queue (all environments).
    config.active_job.queue_adapter = :solid_queue

    # Meal generator provider — "deals" ranks recipes by active weekly savings.
    # Swap to "mock" for random selection, or "anthropic"/"openai" when AI is ready.
    config.meal_ai_provider = "deals"

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
