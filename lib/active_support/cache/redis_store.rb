require 'redis'

# This is a direct port of ActiveSupport::Cache::MemCacheStore
# Drop this file in lib/active_support/cache/redis_store and in your env files
# add:
#
# config.cache_store = :redis_store

module ActiveSupport
  module Cache
    class RedisStore < Store

      # Pass Redis-like instance or args to Redis#new
      def initialize(*args)
        if args.first.respond_to?(:get)
          @data = args.first
        else
          @data = Redis.new(*args)
        end

        # TODO: Does it make sense to use LocalCache?
        # extend Strategy::LocalCache
      end

      # Reads multiple keys from the cache.
      def read_multi(*keys)
        options = nil
        options = keys.pop if keys.last.is_a?(Hash)
        @data.mget(*keys).map { |v| deserialize(v, options) }
      rescue Redis::ProtocolError => e
        logger.error("Redis (#{e}): #{e.message}")
        []
      end

      def read(key, options = nil) # :nodoc:
        super
        deserialize( @data.get(key), options )
      rescue Redis::ProtocolError => e
        logger.error("Redis (#{e}): #{e.message}")
        nil
      end

      # Writes a value to the cache.
      #
      # Possible options:
      # - +:unless_exist+ - set to true if you don't want to update the cache
      # if the key is already set.
      # - +:expires_in+ - the number of seconds that this value may stay in
      # the cache. See ActiveSupport::Cache::Store#write for an example.
      def write(key, value, options = nil)
        super
        method = options && options[:unless_exist] ? :setnx : :set
        value = serialize(value, options)
        response = @data.send(method, key, value)
        expires = expires_in(options)
        @data.expire(key, expires) unless expires.zero?
        response == "OK"
      rescue Redis::ProtocolError => e
        logger.error("Redis (#{e}): #{e.message}")
        false
      end

      def delete(key, options = nil) # :nodoc:
        super
        response = @data.del(key)
        response > 0
      rescue Redis::ProtocolError => e
        logger.error("Redis (#{e}): #{e.message}")
        false
      end

      def exist?(key, options = nil) # :nodoc:
        super
        @data.exists(key)
      rescue Redis::ProtocolError => e
        logger.error("Redis (#{e}): #{e.message}")
        nil
      end

      def increment(key, amount = 1) # :nodoc:
        log("incrementing", key, amount)
        @data.incrby(key, amount)
      rescue Redis::ProtocolError => e
        logger.error("Redis (#{e}): #{e.message}")
        nil
      end

      def decrement(key, amount = 1) # :nodoc:
        log("decrementing", key, amount)
        @data.decrby(key, amount)
      rescue Redis::ProtocolError => e
        logger.error("Redis (#{e}): #{e.message}")
        nil
      end

      def delete_matched(matcher, options = nil) # :nodoc:
        super
        keys = @data.keys(matcher)
        @data.del(*keys)
      rescue Redis::ProtocolError => e
        logger.error("Redis (#{e}): #{e.message}")
        false
      end

      def clear
        @data.flushdb
      end

      def stats
        @data.info
      end

      private
        def raw?(options)
          options && options[:raw] == true
        end

        def serialize(value, options)
          raw?(options) ? value : Marshal.dump(value)
        end

        def deserialize(value, options)
          value.nil? || raw?(options) ? value : Marshal.load(value)
        end
    end
  end
end