# getv

[![Gem Version](https://badge.fury.io/rb/getv.svg)](https://rubygems.org/gems/getv)

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
    2.1.3



GLOBAL OPTIONS
    --help          - Show this message
    -j, --json      - Output in json
    -l, --latest    - Latest version
    -p, --proxy=arg - Web proxy (default: none)
    --version       - Display the program version



COMMANDS
    docker         - Get package versions from a Docker or OCI container image registry
    gem            - Get package versions from RubyGems.org
    github_commit  - Get package versions from GitHub commits
    github_release - Get package versions from GitHub releases
    github_tag     - Get package versions from GitHub tags
    helm           - Get package versions from a Helm chart repository
    help           - Shows a list of commands or help for one command
    npm            - Get package versions from npm at registry.npmjs.org
    pypi           - Get package versions from the Python Package Index at pypi.org
    text           - Get package versions from text file URL
    xml            - Get package versions from XML file URL
```

### CLI examples

Show the latest available version of the `getv` gem:

```console
$ getv --latest gem getv
2.1.3
```

Show all `dep` GitHub release versions in JSON:

```console
$ getv --json github_release golang/dep
{"name":"golang/dep","versions":["0.2.0","0.2.1","0.3.0","0.3.1","0.3.2","0.4.0","0.4.1","0.5.0","0.5.1","0.5.2","0.5.3","0.5.4"]}
```

Show all AtomicParsley Github release versions:

```console
$ getv github_release --invalid_versions wez/atomicparsley
20200701.154658.b0d6223
20201231.092811.cbecfb1
20210114.184825.1dbe1be
20210124.204813.840499f
20210617.200601.1ac7c08
20210715.151551.e7ad03a
```

Show the latest stable version of Kubernetes using the release text file URL:

```console
$ getv -l text --url=https://storage.googleapis.com/kubernetes-release/release/stable.txt kubernetes
1.23.2
```

Show selected semantic versions of the `apache/superset` Docker image in JSON:

```console
$ getv --json docker --reject '-' --semantic_select '~>1.3.0,!=1.3.1' apache/superset
{"name":"apache/superset","versions":["1.3.0","1.3.2"]}
```

Show all versions of `libnetfilter_acct` using selected link values (`<a>` HTML elements) on an indexed web page:

```console
$ getv xml --url=https://netfilter.org/projects/libnetfilter_acct/files --xpath '//a' --select_search='^.*libnetfilter_acct-([\d\.]*)\.tar\.bz2$' libnetfilter_acct
1.0.0
1.0.1
1.0.2
1.0.3
```

Show the latest GitHub commit to the `main` branch of the `getv` project in a useful versioning format:

```console
# By default the \2 capture group contains the date and \5 contains the short commit hash
$ getv -l github_commit --select_replace '\2git\5' --branch main liger1978/getv
20220123git9ed86f0
```

## Ruby library

Example:

```ruby
require 'getv'

superset = Getv::Package::Docker.new 'apache/superset', reject: '-'
puts superset.versions
puts superset.latest_version

# You can also use the flexible "create" factory method
Getv::Package.create 'apache/superset', type: 'docker', reject: '-'
Getv::Package.create 'golang/dep', type: 'github release'
Getv::Package.create 'golang/dep', type: 'github_release'
Getv::Package.create 'golang/dep', type: 'GitHub::Release'
Getv::Package.create 'rubygem-getv'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. Run `bundle exec rubocop` to run the linter. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Note that by default, Bundler will attempt to install gems to the system, e.g. `/usr/bin`, `/usr/share`, which requires elevated access and can interfere with files that are managed by the system's package manager. This behaviour can be overridden by creating the file `.bundle/config` and adding the following line:
```
BUNDLE_PATH: "./.bundle"
```
When you run `bin/setup` or `bundle install`, all gems will be installed inside the .bundle directory of this project.

To make this behaviour a default for all gem projects, the above line can be added to the user's bundle config file in their home directory (`~/.bundle/config`)

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/liger1978/getv).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
