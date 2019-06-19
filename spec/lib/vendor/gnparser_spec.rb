require 'rails_helper'
describe 'TaxonWorks::Vendor::Gnparser', type: :model, group: [:nomenclature] do

  let(:parser) { TaxonWorks::Vendor::Gnparser::Parser.new }

  specify '.new' do
    expect(TaxonWorks::Vendor::Gnparser::Parser.new).to be_truthy
  end

  specify '#client' do
    expect(parser.client.class).to eq(GNparser::Client) 
  end

  specify 'with text' do
    expect(parser.client.parse('Aus bus')).to be_truthy
  end

end
