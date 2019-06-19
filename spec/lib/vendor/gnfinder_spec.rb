require 'rails_helper'
describe 'TaxonWorks::Vendor::Gnfinder', type: :model, group: [:nomenclature] do

  let(:finder) { TaxonWorks::Vendor::Gnfinder::Finder.new }

  specify '.new' do
    expect(TaxonWorks::Vendor::Gnfinder::Finder.new).to be_truthy
  end

  specify '#client' do
    expect(finder.client.class).to eq(Gnfinder::Client) 
  end

  specify '#find_names' do
    expect(finder.client.find_names('Aus bus')).to be_truthy
  end

end
