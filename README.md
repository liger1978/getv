# Getv

Pull package version numbers from the web in various ways.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'getv'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install getv

## Usage

```
irb(main):024:0> superset = Getv::Package.new('superset',{:type => 'docker', :owner => 'apache', :reject => '-'})
=>
#<Getv::Package:0x000055b6d2326f20
...
irb(main):025:0> superset.get_versions
=> ["1.0.0", "1.0.1", "1.1.0", "1.2.0", "1.3.0", "1.3.1", "1.3.2"]
irb(main):026:0> superset.get_latest_version
=> "1.3.2"
irb(main):027:0> superset
=>
#<Getv::Package:0x000055b6d2326f20
 @name="superset",
 @opts=
  {:owner=>"apache",
   :repo=>"superset",
   :url=>"https://registry.hub.docker.com",
   :type=>"docker",
   :select=>{:search=>"^\\s*v?((0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?)\\s*$", :replace=>"\\1"},
   :reject=>"-",
   :semantic_only=>true,
   :semantic_select=>["*"],
   :versions=>["1.0.0", "1.0.1", "1.1.0", "1.2.0", "1.3.0", "1.3.1", "1.3.2"],
   :latest_version=>"1.3.2"}>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/liger1978/getv.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
