gem 'minitest' # make sure we get the gem, not stdlib
require 'minitest'
require "minitest/autorun"

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))

require 'active_support'
require 'active_support/inflector'
require 'mocha/setup' # FIXME: stop using mocha

require 'cache_store_behavior'
require 'local_cache_behavior'
require 'cache_increment_decrement_behavior'
require 'encoded_key_cache_behavior'
require 'autoloading_cache_behavior'

class SpymemcachedStoreTest < ::Minitest::Test

  def setup
    @cache = @@cache ||= ActiveSupport::Cache.lookup_store(:spymemcached_store, :expires_in => 60)
    @peek = @@peek ||= ActiveSupport::Cache.lookup_store(:spymemcached_store)
    @data = @cache.instance_variable_get(:@client)
    @cache.clear
    @cache.silence!
    @cache.logger = ActiveSupport::Logger.new("/dev/null")
  end

  include CacheStoreBehavior
  include LocalCacheBehavior
  include CacheIncrementDecrementBehavior
  include EncodedKeyCacheBehavior
  include AutoloadingCacheBehavior

  def test_raw_values
    cache = @peek
    cache.write("foo", 2)
    #spymemcached returns right type
    assert_equal 2, cache.read("foo")
  end

  def test_raw_values_with_marshal
    cache = ActiveSupport::Cache.lookup_store(:spymemcached_store, :raw => true)
    cache.clear
    cache.write("foo", Marshal.dump([]))
    assert_equal [], cache.read("foo")
  end

  def test_local_cache_raw_values
    cache = ActiveSupport::Cache.lookup_store(:spymemcached_store, :raw => true)
    cache.clear
    cache.with_local_cache do
      cache.write("foo", '2')
      assert_equal "2", cache.read("foo")
    end
  end

  def test_local_cache_raw_values_with_marshal
    cache = ActiveSupport::Cache.lookup_store(:spymemcached_store, :raw => true)
    cache.clear
    cache.with_local_cache do
      cache.write("foo", Marshal.dump([]))
      assert_equal [], cache.read("foo")
    end
  end

  def test_read_should_return_a_different_object_id_each_time_it_is_called
    cache = ActiveSupport::Cache.lookup_store(:spymemcached_store, :raw => true)
    cache.write('foo', 'bar')
    value = cache.read('foo')
    assert_not_equal value.object_id, cache.read('foo').object_id
    value << 'bingo'
    assert_not_equal value, cache.read('foo')
  end

  def test_namespace
    cache = ActiveSupport::Cache.lookup_store(:spymemcached_store, :namespace => "abc")
    cache.write('foo', 'bar')
    assert_equal 'bar', cache.read('foo')
    assert_nil @cache.read('foo')
    assert_equal 'bar', @cache.read('abc:foo')
  end

  def test_raw_option
    @cache.write('foo', '1')
    assert_equal '1', @cache.read('foo')
    assert_equal -1, @cache.increment('foo')

    @cache.write('bar', '1', :raw => true)
    assert_equal '1', @cache.read('bar')
    assert_equal 2, @cache.increment('bar')
  end

  def assert_not_equal(expected, result)
    assert expected != result, "expect #{expected.inspect} not equal #{result.inspect}"
  end

  def assert_nothing_raised(&block)
    block.call
  rescue => e
    fail("expected nothing raised, but caught #{e.class}: #{e.message}")
  end
end
