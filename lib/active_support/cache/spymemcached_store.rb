require 'active_support/cache'
require 'spymemcached'

module ActiveSupport
  module Cache
    class SpymemcachedStore < ActiveSupport::Cache::Store

      def initialize(*addresses)
        addresses = addresses.flatten
        options = addresses.extract_options!
        super(options)

        unless [String, Spymemcached, NilClass].include?(addresses.first.class)
          raise ArgumentError, "First argument must be an empty array, an array of hosts or a Spymemcached instance."
        end
        @client = if addresses.first.is_a?(Spymemcached)
          addresses.first
        else
          mem_cache_options = options.dup
          UNIVERSAL_OPTIONS.each{|name| mem_cache_options.delete(name)}
          Spymemcached.new(addresses, mem_cache_options)
        end

        extend Strategy::LocalCache
        extend LocalCacheWithRaw
      end

      # Read multiple values at once from the cache. Options can be passed
      # in the last argument.
      #
      # Some cache implementation may optimize this method.
      #
      # Returns a hash mapping the names provided to the values found.
      def read_multi(*names)
        options = names.extract_options!
        options = merged_options(options)
        keys_to_names = Hash[names.map{|name| [namespaced_key(name, options), name]}]
        raw_values = @client.get_multi(keys_to_names.keys)
        values = {}
        raw_values.each do |key, value|
          entry = deserialize_entry(value)
          values[keys_to_names[key]] = entry.value unless entry.expired?
        end
        values
      end

      # Increment an integer value in the cache.
      #
      # Options are passed to the underlying cache implementation.
      #
      # All implementations may not support this method.
      def increment(name, amount = 1, options = nil)
        options = merged_options(options)

        instrument(:increment, name, :amount => amount) do
          @client.incr(name, amount)
        end
      rescue Spymemcached::Error => e
        logger.error("Spymemcached::Error (#{e}): #{e.message}") if logger
        nil
      end

      # Decrement an integer value in the cache.
      #
      # Options are passed to the underlying cache implementation.
      #
      # All implementations may not support this method.
      def decrement(name, amount = 1, options = nil)
        options = merged_options(options)

        instrument(:decrement, name, :amount => amount) do
          @client.decr(name, amount)
        end
      rescue Spymemcached::Error => e
        logger.error("Spymemcached::Error (#{e}): #{e.message}") if logger
        nil
      end

      # Clear the entire cache. Be careful with this method since it could
      # affect other processes if shared cache is being used.
      #
      # The options hash is passed to the underlying cache implementation.
      #
      # All implementations may not support this method.
      def clear(options = nil)
        @client.flush_all
      rescue Spymemcached::Error => e
        logger.error("Spymemcached::Error (#{e}): #{e.message}") if logger
        nil
      end

      # Get the statistics from the memcached servers.
      def stats
        @client.stats
      end

      protected
      # Read an entry from the cache implementation. Subclasses must implement
      # this method.
      def read_entry(key, options) # :nodoc:
        deserialize_entry(@client.get(key))
      rescue Spymemcached::Error => e
        logger.error("Spymemcached::Error (#{e}): #{e.message}") if logger
        nil
      end

      # Write an entry to the cache implementation. Subclasses must implement
      # this method.
      def write_entry(key, entry, options) # :nodoc:
        method = options && options[:unless_exist] ? :add : :set
        value = options[:raw] ? entry.value.to_s : entry
        expires_in = options[:expires_in].to_i
        if expires_in > 0 && !options[:raw]
          # Set the memcache expire a few minutes in the future to support race condition ttls on read
          expires_in += 5.minutes
        end
        @client.send(method, key, value, expires_in)
      rescue Spymemcached::Error => e
        logger.error("Spymemcached::Error (#{e}): #{e.message}") if logger
        false
      end

      # Delete an entry from the cache implementation. Subclasses must
      # implement this method.
      def delete_entry(key, options) # :nodoc:
        @client.delete(key)
      rescue Spymemcached::Error => e
        logger.error("Spymemcached::Error (#{e}): #{e.message}") if logger
        false
      end

      protected
      def deserialize_entry(raw_value)
        if raw_value
          entry = Marshal.load(raw_value) rescue raw_value
          entry.is_a?(Entry) ? entry : Entry.new(entry)
        else
          nil
        end
      end

      # Provide support for raw values in the local cache strategy.
      module LocalCacheWithRaw # :nodoc:
        protected
        def read_entry(key, options)
          entry = super
          if options[:raw] && local_cache && entry
             entry = deserialize_entry(entry.value)
          end
          entry
        end

        def write_entry(key, entry, options) # :nodoc:
          retval = super
          if options[:raw] && local_cache && retval
            raw_entry = Entry.new(entry.value.to_s)
            raw_entry.expires_at = entry.expires_at
            local_cache.write_entry(key, raw_entry, options)
          end
          retval
        end
      end
    end
  end
end
