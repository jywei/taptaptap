require 'spec_helper'

describe Remote::Posting do
  context 'data reading' do
    let(:posting) { Remote::Posting.new({ category: 'test', city: 'NY' }) }

    it { expect(posting.category).to eq('test') }
    it { expect(posting.source).to be_nil }
  end

  context 'validation' do
    it { expect(Remote::Posting.new(category: 'APET', source: 'CRAIG', status: 'for_sale', posting_state: 'available', flagged_status: 0)).to be_valid }
    it { expect(Remote::Posting.new(source: 'test')).to have(1).error_on(:source) }
    it { expect(Remote::Posting.new(category: 'test')).to have(1).error_on(:category) }
  end
end
