# frozen_string_literal: true

require 'redis'
require 'janus/errors'
require 'janus/logger'

module Janus
  module DbSwitcher
    extend ::Janus::Logger

    def self.enabled?
      ENV['JANUS_ENABLED'] == 'true'
    end

    def self.switch(database_name = nil)
      return nil unless enabled?

      database_name ||= db_from_redis
      raise SwitchError, 'Empty database_name' if database_name.nil? || database_name.empty?

      if current == database_name
        log(:info, "Already connected to #{database_name}")
        return true
      end

      config = ActiveRecord::Base.connection_db_config.configuration_hash.dup
      config[:database] = database_name

      begin
        ActiveRecord::Base.connection_pool.disconnect!
        ActiveRecord::Base.establish_connection(config)
        unless current == database_name
          raise SwitchError, "Switch failed, still on #{current}, wanted #{database_name}"
        end

        log(:info, "Switched database to: #{database_name}")
        true
      rescue StandardError => e
        raise SwitchError, "Failed to switch database: #{e.message}"
      end
    end

    def self.current
      ActiveRecord::Base.connection.current_database
    end

    def self.db_from_redis
      host = ENV['JANUS_REDIS_HOST'] || 'localhost'
      password = ENV.fetch('JANUS_REDIS_PASS', nil)
      namespace = ENV['JANUS_NAMESPACE'] || 'janus'
      key = ENV['JANUS_APP_NAME'] || 'current_db_name'

      r = Redis::Namespace.new(namespace, redis: Redis.new(host: host, password: password))
      r.get(key)
    end
  end
end
