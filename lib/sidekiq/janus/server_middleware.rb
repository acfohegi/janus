# frozen_string_literal: true

module Sidekiq
  module Janus
    class ServerMiddleware
      def call(_worker, job, _queue)
        db_name = job['database_name']
        Sidekiq.logger.info("Switching database for job #{job['class']} to #{db_name}")
        ::Janus::DbSwitcher.switch(db_name)
        yield
      end
    end
  end
end
