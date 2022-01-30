# frozen_string_literal: true

RSpec.describe Getv::Package, :vcr do
  let :default_opts do
    {
      latest_version: nil,
      proxy: nil,
      reject: nil,
      select_replace: '\\1',
      select_search: '^\\s*v?(.*)\\s*$',
      semantic_only: true,
      semantic_select: ['*'],
      versions: nil
    }
  end

  context 'when type is unset' do
    context 'when name starts with rubygem' do
      let :package do
        described_class.new 'rubygem-mypackage'
      end

      it 'sets type to gem' do
        expect(package.opts[:type]).to eq 'gem'
      end

      it 'removes rubgem prefix from package name' do
        expect(package.opts[:gem]).to eq 'mypackage'
      end
    end

    context 'when name starts with python' do
      let :package do
        described_class.new 'python-mypackage'
      end

      it 'sets type to pypi' do
        expect(package.opts[:type]).to eq 'pypi'
      end

      it 'removes python prefix from package name' do
        expect(package.opts[:pypi]).to eq 'mypackage'
      end
    end

    context 'when name starts with nodejs' do
      let :package do
        described_class.new 'nodejs-mypackage'
      end

      it 'sets type to npm' do
        expect(package.opts[:type]).to eq 'npm'
      end

      it 'removes nodejs prefix from package name' do
        expect(package.opts[:npm]).to eq 'mypackage'
      end
    end
  end

  context 'when type is set to docker' do
    let :default_docker_opts do
      {
        password: nil,
        proxy: nil,
        type: 'docker',
        url: 'https://registry.hub.docker.com',
        user: nil
      }
    end

    context 'with a single forward slash in name' do
      let :package do
        described_class.new 'mynamespace/mypackage', type: 'docker'
      end

      it 'correctly sets owner and repo options' do
        expected_opts = default_opts.merge(default_docker_opts).merge({ owner: 'mynamespace', repo: 'mypackage' })
        expect(package.opts).to eq expected_opts
      end
    end

    context 'with two forward slashes in name' do
      let :package do
        described_class.new 'foobar.com/mynamespace/mypackage', type: 'docker'
      end

      it 'correctly sets owner, repo and url options' do
        expected_opts = default_opts.merge(default_docker_opts).merge(
          { owner: 'mynamespace', repo: 'mypackage', url: 'https://foobar.com' }
        )
        expect(package.opts).to eq expected_opts
      end
    end

    context 'with three forward slashes in name' do
      let :package do
        described_class.new 'foobar.com/mynamespace/mypackage/mysubpackage', type: 'docker'
      end

      it 'correctly sets owner, repo and url options' do
        expected_opts = default_opts.merge(default_docker_opts).merge(
          { owner: 'mynamespace', repo: 'mypackage/mysubpackage', url: 'https://foobar.com' }
        )
        expect(package.opts).to eq expected_opts
      end
    end

    context 'when versions method is called' do
      let :package do
        described_class.new 'superset', type: 'docker', owner: 'apache', reject: '-'
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

  context 'when type is set to gem' do
    context 'when versions method is called' do
      let :expected_versions do
        ['7.5.0', '7.6.1', '7.7.0', '7.8.0', '7.9.0', '7.10.0', '7.11.0', '7.12.0', '7.12.1', '7.13.1']
      end

      let :package do
        described_class.new 'puppet', type: 'gem', reject: '-'
      end

      before do
        package.versions
      end

      after do
        package.opts.delete :versions
        package.opts.delete :latest_version
      end

      it 'returns correct versions' do
        expect(package.opts[:versions][-10..-1]).to eq expected_versions
      end

      it 'returns latest version' do
        expect(package.opts[:latest_version]).to eq expected_versions.last
      end
    end
  end

  context 'when type is set to github_tag' do
    context 'when versions method is called' do
      let :expected_versions do
        ['1.4.0', '1.4.1', '1.4.2', '1.4.3', '1.4.4', '1.5.0', '1.5.1', '1.6.0', '1.6.1', '1.7.0']
      end

      let :package do
        described_class.new 'webrick', type: 'github_tag', owner: 'ruby', reject: '-'
      end

      before do
        package.versions
      end

      after do
        package.opts.delete :versions
        package.opts.delete :latest_version
      end

      it 'returns correct versions' do
        expect(package.opts[:versions][-10..-1]).to eq expected_versions
      end

      it 'returns latest version' do
        expect(package.opts[:latest_version]).to eq expected_versions.last
      end

      ##    it 'has the right options' do
      ##      expect(package.opts.reject! { |k, _v| %i[latest_version versions].include?(k) }).to eq(default_opts)
      ##    end
    end
  end

  context 'when type is set to github_release' do
    context 'when versions method is called' do
      let :expected_versions do
        ['2.2.3', '2.2.4', '2.3.0', '2.3.1', '2.3.2', '2.3.3', '2.3.4', '2.3.5', '2.4.0', '2.4.1']
      end

      let :expected_opts do
        default_opts.merge(owner: 'goharbor', repo: 'harbor', type: 'github_release')
      end

      let :package do
        described_class.new 'harbor', type: 'github_release', owner: 'goharbor', reject: '-'
      end

      before do
        package.versions
      end

      after do
        package.opts.delete :versions
        package.opts.delete :latest_version
      end

      it 'returns correct versions' do
        expect(package.opts[:versions][-10..-1]).to eq expected_versions
      end

      it 'returns latest version' do
        expect(package.opts[:latest_version]).to eq expected_versions.last
      end

      ##    it 'has the right options' do
      ##      expect(package.opts.reject! { |k, _v| %i[latest_version versions].include?(k) }).to eq(expected_opts)
      ##    end
    end
  end
end
