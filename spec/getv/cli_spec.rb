# frozen_string_literal: true

RSpec.describe 'Getv:Cli' do # rubocop:disable RSpec/DescribeClass
  specify 'getv help' do
    expect { system %(./exe/getv help) }
      .to output(a_string_including('Show this message'))
      .to_stdout_from_any_process
  end

  specify 'getv help docker' do
    expect { system %(./exe/getv help docker) }
      .to output(a_string_including('Get package versions from a Docker or OCI container image registry'))
      .to_stdout_from_any_process
  end

  specify 'getv help gem' do
    expect { system %(./exe/getv help gem) }
      .to output(a_string_including('Get package versions from RubyGems.org'))
      .to_stdout_from_any_process
  end

  specify 'getv help get' do
    expect { system %(./exe/getv help get) }
      .to output(a_string_including('Get package versions from text file URL'))
      .to_stdout_from_any_process
  end

  specify 'getv help github_commit' do
    expect { system %(./exe/getv help github_commit) }
      .to output(a_string_including('Get package versions from GitHub commits'))
      .to_stdout_from_any_process
  end

  specify 'getv help github_release' do
    expect { system %(./exe/getv help github_release) }
      .to output(a_string_including('Get package versions from GitHub releases'))
      .to_stdout_from_any_process
  end

  specify 'getv help github_tag' do
    expect { system %(./exe/getv help github_tag) }
      .to output(a_string_including('Get package versions from GitHub tags'))
      .to_stdout_from_any_process
  end

  specify 'getv help index' do
    expect { system %(./exe/getv help index) }
      .to output(a_string_including('Get package versions from web page of links'))
      .to_stdout_from_any_process
  end

  specify 'getv help npm' do
    expect { system %(./exe/getv help npm) }
      .to output(a_string_including('Get package versions from npm at registry.npmjs.org'))
      .to_stdout_from_any_process
  end

  specify 'getv help pypi' do
    expect { system %(./exe/getv help pypi) }
      .to output(a_string_including('Get package versions from the Python Package Index at pypi.org'))
      .to_stdout_from_any_process
  end

  specify 'getv docker' do
    expect { system %(./exe/getv docker 2>&1) }
      .to output(a_string_including('error: parse error'))
      .to_stdout_from_any_process
  end

  specify 'getv -y docker package' do
    expect { system %(./exe/getv -y docker package 2>&1) }
      .to output(a_string_including('error: Unknown option -y'))
      .to_stdout_from_any_process
  end
end
