# frozen_string_literal: true

require 'janus/db_switcher'
require 'logger'
require 'active_record'
require 'ostruct'

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

# Stub Rails logger
module Rails
  def self.logger
    @logger ||= Logger.new(IO::NULL)
  end
end

# Stub Sidekiq server and logger
module Sidekiq
  def self.server?
    false
  end

  def self.logger
    @logger ||= Logger.new(IO::NULL)
  end
end

ConfigStruct = Struct.new(:configuration_hash)

ENV['JANUS_ENABLED'] = 'true'

RSpec.configure do |config|
  config.before do
    allow(ActiveRecord::Base).to receive(:connection_db_config).and_return(ConfigStruct.new({}))
    conn_pool = instance_double(ActiveRecord::ConnectionAdapters::ConnectionPool, disconnect!: true)
    allow(ActiveRecord::Base).to receive_messages(
      connection_pool: conn_pool,
      establish_connection: true
    )
  end
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
