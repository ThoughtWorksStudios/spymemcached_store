# SpymemcachedStore

This is Rails 4 compatible cache store for [spymemcached.jruby](https://github.com/ThoughtWorksStudios/spymemcached.jruby)
to replace Rails' default memcache client Dalli on JRuby platform.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spymemcached_store'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spymemcached_store

## Usage

    config.cache_store = :spymemcached_store, { :expires_in => 60, :namespace => 'app-namespace', :timeout => 0.1 }

Supports all Rails cache store options, see [spymemcached.jruby](https://github.com/ThoughtWorksStudios/spymemcached.jruby) for additional options.

It is not recommended to use :compress and :compress_threshold options, as spymemcached.jruby does it by default.

## Credits

Most of code including tests is coming from Rails codebase v4.1.6.
Only replaced Dalli related part with spymemcached.jruby to keep API compatible.

## Contributing

1. Fork it ( https://github.com/ThoughtWorksStudios/spymemcached_store/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
