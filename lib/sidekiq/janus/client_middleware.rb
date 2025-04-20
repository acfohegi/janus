# frozen_string_literal: true

require 'janus/logger'

module Sidekiq
  module Janus
    class ClientMiddleware
      include ::Janus::Logger

      def call(worker_class, job, _queue, _redis_pool)
        j = ::Janus::DbSwitcher
        current_db = Sidekiq.server? ? j.db_from_redis : j.current
        job['database_name'] = current_db
        log(:info, "Tagged #{worker_class} with database #{current_db}")
        yield
      end
    end
  end
end
