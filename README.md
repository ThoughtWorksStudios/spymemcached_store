# SpymemcachedStore

This is Rails 4 compatible cache store for [spymemcached.jruby](https://github.com/ThoughtWorksStudios/spymemcached.jruby)

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

    ActiveSupport::Cache.lookup_store(:spymemcached_store, :expires_in => 60, :namespace => 'app-namespace')

Supports all Rails cache store options, see [spymemcached.jruby](https://github.com/ThoughtWorksStudios/spymemcached.jruby) for additional options.

It is not recommended to use :compress and :compress_threshold options, as spymemcached.jruby does it by default.

## Contributing

1. Fork it ( https://github.com/ThoughtWorksStudios/spymemcached_store/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
