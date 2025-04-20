# frozen_string_literal: true

require 'mock_redis'

def stub_redis_with_namespace_mock
  stub_const('Redis', MockRedis)
  stub_const('Redis::Namespace', Class.new do
    def initialize(_namespace, redis:)
      @redis = redis
    end

    def get(key)
      @redis.get(key)
    end
  end)
end
