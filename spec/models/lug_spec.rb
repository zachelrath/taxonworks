require 'rails_helper'

RSpec.describe Lug, type: :model do
  let(:lug) { Lug.new }

  context 'validation' do
    before { lug.valid? }

    specify '#text required' do
      expect(lug.errors).to include(:text)
    end
  end


end
