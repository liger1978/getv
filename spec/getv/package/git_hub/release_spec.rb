# frozen_string_literal: true

RSpec.describe Getv::Package::GitHub::Release, :vcr do
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

  context 'when versions method is called' do
    let :expected_versions do
      ['2.2.3', '2.2.4', '2.3.0', '2.3.1', '2.3.2', '2.3.3', '2.3.4', '2.3.5', '2.4.0', '2.4.1']
    end

    let :expected_opts do
      default_opts.merge(owner: 'goharbor', repo: 'harbor')
    end

    let :package do
      described_class.new 'harbor', owner: 'goharbor', reject: '-'
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
