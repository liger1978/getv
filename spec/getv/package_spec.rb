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

  context 'when factory method is used' do
    context 'when name starts with rubygem' do
      let :package do
        described_class.create 'rubygem-mypackage'
      end

      it 'sets package class to Getv::Package::Gem' do
        expect(package.class).to eq Getv::Package::Gem
      end

      it 'removes rubgem prefix from package name' do
        expect(package.opts[:gem]).to eq 'mypackage'
      end
    end

    context 'when name starts with python' do
      let :package do
        described_class.create 'python-mypackage'
      end

      it 'sets package class to Getv::Package::Pypi' do
        expect(package.class).to eq Getv::Package::Pypi
      end

      it 'removes python prefix from package name' do
        expect(package.opts[:pypi]).to eq 'mypackage'
      end
    end

    context 'when name starts with nodejs' do
      let :package do
        described_class.create 'nodejs-mypackage'
      end

      it 'sets package class to Getv::Package::Npm' do
        expect(package.class).to eq Getv::Package::Npm
      end

      it 'removes nodejs prefix from package name' do
        expect(package.opts[:npm]).to eq 'mypackage'
      end
    end
  end
end
