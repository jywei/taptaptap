require 'spec_helper'

describe Posting do
  posting_environment_helpers

  before(:each) do
    SystemData.delete_all
  end

  describe 'validations' do
    it 'should be valid' do
      expect(FactoryGirl.build(:posting)).to be_valid
    end

    context 'category' do
      let(:posting) { FactoryGirl.build(:posting, category: 'INVCAT') }

      it 'contains invalid category' do
        expect(posting).to be_invalid
        expect(posting).to have(1).error_on(:category)
        expect(posting.errors[:category]).to include("is not included in list: INVCAT")
      end
    end
  end

  describe '#anchor' do
    it 'generates token for every posting' do
      expect(FactoryGirl.create(:posting).anchor).to_not be_blank
    end
  end

  #describe '#store' do
  #  context 'for valid params' do
  #    let(:params) { FactoryGirl.attributes_for(:posting) }
  #    let(:posting) { Posting.new(params) }
  #
  #    it 'stores posting to database' do
  #      posting.store
  #      expect(posting.new_record?).to be_false
  #    end
  #
  #    it 'returns response object' do
  #      expect(posting.store).to eq({ error_response: Posting.last.id, wait_for: 1 })
  #    end
  #
  #    it 'handles location with geoapi' do
  #      params = FactoryGirl.attributes_for(:posting).merge({ location: { lat: '-10', long: '20' }})
  #      posting_with_location = Posting.new(params)
  #      GeoApi.stub(:fetch_locations).and_return({ success: true, country: 'Ukraine' }.to_json)
  #      posting_with_location.store
  #      expect(posting_with_location.reload.location[:country]).to eq('Ukraine')
  #    end
  #  end
  #
  #  context 'for not valid params' do
  #    let(:params) { FactoryGirl.attributes_for(:posting).except(:heading) }
  #    let(:posting) { Posting.new(params) }
  #
  #    it 'does not store posting to database' do
  #      posting.store
  #      expect(posting.new_record?).to be_true
  #    end
  #
  #    it 'returns response object' do
  #      expect(posting.store).to eq({ error_response: "Heading can't be blank", wait_for: 1 })
  #    end
  #  end
  #end

  describe 'category group' do
    it 'should match category group by category' do
      expect(Posting::CATEGORY_RELATIONS_REVERSE['MADU']).to eq('MMMM')
      expect(Posting::CATEGORY_RELATIONS_REVERSE['SAPP']).to eq('SSSS')
      expect(Posting::CATEGORY_RELATIONS_REVERSE['SADDPP']).to be_nil
    end
  end

  describe 'partitioning' do
    subject { Posting }

    before do
      Posting.destroy_all
      FactoryGirl.create(:posting, created_at: Date.yesterday)
      FactoryGirl.create(:posting)
      FactoryGirl.create(:posting, created_at: Date.tomorrow)
    end

    it 'selects all records' do
      expect(Posting.count).to eq(3)
    end
  end
end
