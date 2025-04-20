# frozen_string_literal: true

module Janus
  module Logger
    def logger
      defined?(Sidekiq) && Sidekiq.server? ? Sidekiq.logger : Rails.logger
    end

    def log(level, message)
      logger.public_send(level, "[E2eDbSwitcher] #{message}")
    end
  end
end
