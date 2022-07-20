# frozen_string_literal: true

RSpec.describe Getv::Package::GitHub::Tag, :vcr do
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
      ['1.4.0', '1.4.1', '1.4.2', '1.4.3', '1.4.4', '1.5.0', '1.5.1', '1.6.0', '1.6.1', '1.7.0']
    end

    let :package do
      described_class.new 'webrick', owner: 'ruby', reject: '-'
    end

    before do
      package.versions
    end

    after do
      package.opts.delete :versions
      package.opts.delete :latest_version
    end

    it 'returns correct versions' do
      expect(package.opts[:versions][-10..]).to eq expected_versions
    end

    it 'returns latest version' do
      expect(package.opts[:latest_version]).to eq expected_versions.last
    end

    ##    it 'has the right options' do
    ##      expect(package.opts.reject! { |k, _v| %i[latest_version versions].include?(k) }).to eq(default_opts)
    ##    end
  end
end
