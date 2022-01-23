# getv

The goal of `getv` is to make it easy and quick to pull software package version numbers from various sources on the web. The application is packaged as a [gem](https://rubygems.org/gems/getv) and provides both a Ruby library and an executable command line tool, `getv`.

## Installation

Install `getv` with:

```
gem install getv
```

Or add this line to your application's Gemfile:

```ruby
gem 'getv'
```

And then execute:

```sh
bundle install
```

## CLI

An executable command tool, `getv` is bundled with this gem:

```console
$ getv
NAME
    getv - Get package version numbers from the web in various ways


SYNOPSIS
    getv [global options] command [command options] [arguments...]


VERSION
    1.1.0



GLOBAL OPTIONS
    --help               - Show this message
    -j, --json           - Output in json
    -l, --latest         - Latest version
    --reject=arg         - Regex version rejection (default: none)
    --select_replace=arg - Regex version selection replace (default: none)
    --select_search=arg  - Regex version selection search (default: none)
    --version            - Display the program version



COMMANDS
    docker         - Get package versions from a Docker or OCI container image registry
    gem            - Get package versions from RubyGems.org
    get            - Get package versions from text file URL
    github_commit  - Get package versions from GitHub commits
    github_release - Get package versions from GitHub releases
    github_tag     - Get package versions from GitHub tags
    help           - Shows a list of commands or help for one command
    index          - Get package versions from web page of links
    npm            - Get package versions from npm at registry.npmjs.org
    pypi           - Get package versions from the Python Package Index at pypi.org
```

### CLI examples

Show the latest available version of the `getv` gem:

```console
$ getv --latest gem getv
1.1.0
```

Show selected semantic versions of the `apache/superset` Docker image in JSON:

```console
$ getv --json --reject '-' docker --semantic_select '~>1.3.0,!=1.3.1' apache/superset
{"name":"apache/superset","versions":["1.3.0","1.3.2"]}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. Run `bundle exec rubocop` to run the linter. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/liger1978/getv).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
