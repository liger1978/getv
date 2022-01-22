# frozen_string_literal: true

RSpec.describe Getv::Package, :vcr do
  context 'when type is set to docker' do
    let :expected_versions do
      ['1.0.0', '1.0.1', '1.1.0', '1.2.0', '1.3.0', '1.3.1', '1.3.2']
    end

    let :package do
      described_class.new 'superset', type: 'docker', owner: 'apache', reject: '-'
    end

    before do
      package.versions
    end

    after do
      package.opts.delete :versions
      package.opts.delete :latest_version
    end

    it 'returns correct versions' do
      expect(package.opts[:versions]).to eq expected_versions
    end

    it 'returns latest version' do
      expect(package.opts[:latest_version]).to eq expected_versions.last
    end
  end

  context 'when type is set to gem' do
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

  context 'when type is set to github_tag' do
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
  end

  context 'when type is set to github_release' do
    let :expected_versions do
      ['2.2.3', '2.2.4', '2.3.0', '2.3.1', '2.3.2', '2.3.3', '2.3.4', '2.3.5', '2.4.0', '2.4.1']
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
  end
end
