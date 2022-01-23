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

Show all `dep` GitHub release versions in JSON:

```console
$ getv --json github_release golang/dep
{"name":"golang/dep","versions":["0.2.0","0.2.1","0.3.0","0.3.1","0.3.2","0.4.0","0.4.1","0.5.0","0.5.1","0.5.2","0.5.3","0.5.4"]}
```

Show all AtomicParsley Github release versions:

```console
$ getv --select_search='(.*)' github_release --invalid_versions wez/atomicparsley
20200701.154658.b0d6223
20201231.092811.cbecfb1
20210114.184825.1dbe1be
20210124.204813.840499f
20210617.200601.1ac7c08
20210715.151551.e7ad03a
```

Show the latest stable version of Kubernetes using the release text file URL:

```console
$ getv -l get --url=https://storage.googleapis.com/kubernetes-release/release/stable.txt kubernetes
1.23.2
```

Show selected semantic versions of the `apache/superset` Docker image in JSON:

```console
$ getv --json --reject '-' docker --semantic_select '~>1.3.0,!=1.3.1' apache/superset
{"name":"apache/superset","versions":["1.3.0","1.3.2"]}
```

Show all versions of `libnetfilter_acct` using selected link values on an indexed web page:

```console
$ getv --select_search='^.*libnetfilter_acct-([\d\.]*)\.tar\.bz2$' index --url=https://netfilter.org/projects/libnetfilter_acct/files --link_value libnetfilter_acct
1.0.0
1.0.1
1.0.2
1.0.3
```

Show the latest GitHub commit to the `main` branch of the `getv` project in a useful versioning format:

```console
# By default the \2 capture group contains the date and \5 contains the short commit hash
$ getv -l --select_replace '\2git\5' github_commit --branch main liger1978/getv
20220123git9ed86f0
```

## Ruby library

Example:

```ruby
require 'getv'

superset = Getv::Package.new 'superset', type: 'docker', owner: 'apache', reject: '-'
puts superset.versions
puts superset.latest_version
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. Run `bundle exec rubocop` to run the linter. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/liger1978/getv).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
