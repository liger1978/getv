# frozen_string_literal: true

RSpec.describe Getv::Package::Gem, :vcr do
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
      ['7.5.0', '7.6.1', '7.7.0', '7.8.0', '7.9.0', '7.10.0', '7.11.0', '7.12.0', '7.12.1', '7.13.1']
    end

    let :package do
      described_class.new 'puppet', reject: '-'
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
