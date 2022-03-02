# frozen_string_literal: true

RSpec.describe Getv::Package::Docker, :vcr do
  let :default_opts do
    {
      latest_version: nil,
      password: nil,
      proxy: nil,
      reject: nil,
      select_replace: '\\1',
      select_search: '^\\s*v?(.*)\\s*$',
      semantic_only: true,
      semantic_select: ['*'],
      url: 'https://registry.hub.docker.com',
      user: nil,
      versions: nil
    }
  end

  context 'with a single forward slash in name' do
    let :package do
      described_class.new 'mynamespace/mypackage'
    end

    it 'correctly sets owner and repo options' do
      expected_opts = default_opts.merge({ owner: 'mynamespace', repo: 'mypackage' })
      expect(package.opts).to eq expected_opts
    end
  end

  context 'with two forward slashes in name' do
    let :package do
      described_class.new 'foobar.com/mynamespace/mypackage'
    end

    it 'correctly sets owner, repo and url options' do
      expected_opts = default_opts.merge(
        { owner: 'mynamespace', repo: 'mypackage', url: 'https://foobar.com' }
      )
      expect(package.opts).to eq expected_opts
    end
  end

  context 'with three forward slashes in name' do
    let :package do
      described_class.new 'foobar.com/mynamespace/mypackage/mysubpackage'
    end

    it 'correctly sets owner, repo and url options' do
      expected_opts = default_opts.merge(
        { owner: 'mynamespace', repo: 'mypackage/mysubpackage', url: 'https://foobar.com' }
      )
      expect(package.opts).to eq expected_opts
    end
  end

  context 'when versions method is called' do
    let :package do
      described_class.new 'superset', owner: 'apache', reject: '-'
    end
    let :expected_versions do
      ['1.0.0', '1.0.1', '1.1.0', '1.2.0', '1.3.0', '1.3.1', '1.3.2']
    end

    after do
      package.opts.delete :versions
      package.opts.delete :latest_version
    end

    before do
      package.versions
    end

    it 'returns correct versions' do
      expect(package.opts[:versions]).to eq expected_versions
    end

    it 'returns latest version' do
      expect(package.opts[:latest_version]).to eq expected_versions.last
    end
    ##      it 'has the right options' do
    ##        expect(package.opts.reject! { |k, _v| %i[latest_version versions].include?(k) }).to eq(default_opts)
    ##      end
  end
end
