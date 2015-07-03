require 'spec_helper'
require 'testing_processor'
def for_test (n=1, attr)
  postings = SystemData.for_test(n, attr)
  posting = postings["postings"].first
  posting.delete('category_group')
  posting.symbolize_keys
end

describe Converter do

  describe '#convert' do

    context 'functionality' do
      before :each do
        Converter.delete_all
      end

      let(:processor) { TestingProcessor.new }

      it 'when category VAUT, category_group' do
        converter = FactoryGirl.create(:converter)
        posting_attributes = { source: converter.source, category: "VAUT"}
        res = converter.convert(for_test(1, posting_attributes), processor )
        expect(res[:category_group]).to eq('VVVV')
      end

      it 'when use_accept_status=true, accept_status=[for_sale] and status != for_sale, errors' do
        converter = FactoryGirl.create(:accept_status_converter)
        posting_attributes = {source: converter.source, category: "VAUT", status: "offered"}
        converter.convert(for_test(1, posting_attributes), processor)
        expect(processor.errors).to include("wrong status")
      end

      it 'when convert_status=true and convert to status = for_sale, status ' do
        converter = FactoryGirl.create(:convert_status_converter)
        posting_attributes = {source: converter.source, category: "VAUT", status: "for_rent"}
        res = converter.convert(for_test(1, posting_attributes), processor)
        expect(res[:status]).to eq("for_sale")
      end

      it 'when use_reject_status=true, reject_status=[for_sale] and status = for_sale, errors' do
        converter = FactoryGirl.create(:reject_status_converter)
        posting_attributes = {source: converter.source, category: "VAUT", status: "for_sale"}
        converter.convert(for_test(1, posting_attributes), processor)
        expect(processor.errors).to include("wrong status")
      end

      it 'when use_accept_state=true, accept_state=[available] and state != available, errors' do
        converter = FactoryGirl.create(:accept_state_converter)
        posting_attributes = { source: converter.source, category: "VAUT", state: "unavailable"}
        converter.convert(for_test(1, posting_attributes), processor)
        expect(processor.errors).to include("wrong state")
      end

      it 'when convert_state=true and convert to state = available, state ' do
        converter = FactoryGirl.create(:convert_state_converter)
        posting_attributes = {source: converter.source, category: "VAUT", state: "expired"}
        res = converter.convert(for_test(1,posting_attributes ), processor)
        expect(res[:posting_state]).to eq("available")
      end

      it 'when use_reject_state=true, reject_state=[available] and state = available, errors' do
        converter = FactoryGirl.create(:reject_state_converter)
        posting_attributes = {source: converter.source, category: "VAUT", state: "available"}
        converter.convert(for_test(1, posting_attributes), processor)
        expect(processor.errors).to include("wrong state")
      end

      it 'when use_accept_flagged_status=true, accept_flagged_status=[1] and flagged_status != 1, errors' do
        converter = FactoryGirl.create(:accept_flagged_status_converter)
        posting_attributes = {source: converter.source, category: "VAUT", flagged_status: "0"}
        converter.convert(for_test(1, posting_attributes), processor)
        expect(processor.errors).to include("wrong flagged_status")
      end

      it 'when convert_flagged_status=true and convert to flagged_status = 1,  flagged_status ' do
        converter = FactoryGirl.create(:convert_flagged_status_converter)
        posting_attributes = {source: converter.source, category: "VAUT", flagged_status: "0"}
        res = converter.convert(for_test(1, posting_attributes), processor)
        expect(res[:flagged_status]).to eq("1")
      end

      it 'when use_reject_flagged_status=true, reject_flagged_status=[1] and flagged_status = 1, errors' do
        converter = FactoryGirl.create(:reject_flagged_status_converter)
        posting_attributes = {source: converter.source, category: "VAUT", flagged_status: "1"}
        converter.convert(for_test(1, posting_attributes), processor)
        expect(processor.errors).to include("wrong flagged_status")
      end

      it 'when use_accept_category=true, accept_category=[VAUT] and category !=[VAUT], errors' do
        converter = FactoryGirl.create(:accept_category_converter)
        posting_attributes = {source: converter.source,  category: "VOTH"}
        converter.convert(for_test(1, posting_attributes), processor)
        expect(processor.errors).to include("wrong category")
      end

      it 'when use_reject_category=true, reject_category=[VAUT] and category =[VAUT], errors' do
        converter = FactoryGirl.create(:reject_category_converter)
        posting_attributes = {source: converter.source, category: "VAUT"}
        converter.convert(for_test(1, posting_attributes), processor)
        expect(processor.errors).to include("wrong category")
      end

      it 'when use_accept_category_group=true, accept_category_group=[VVVV] and category !=[VVVV], errors' do
        converter = FactoryGirl.create(:accept_category_group_converter)
        posting_attributes = {source: converter.source, category: "VAUT"}
        converter.convert(for_test(1, posting_attributes), processor)
        expect(processor.errors).to include("wrong category_group")
      end

      it 'when use_reject_category_group=true, reject_category_group=[VVVV] and category_group =[VVVV], errors' do
        converter = FactoryGirl.create(:reject_category_group_converter)
        posting_attributes = {source: converter.source, category: "VAUT"}
        converter.convert(for_test(1, posting_attributes), processor)
        expect(processor.errors).to include("wrong category_group")
      end

      it 'when posting come without status, status should be' do
        converter = FactoryGirl.create(:converter)
        posting = for_test 1, {source: converter.source}
        posting.delete(:status)
        res = converter.convert(posting, processor)
        expect(res[:status]).to eq("for_sale")
      end

      it 'when posting come without state, state should be' do
        converter = FactoryGirl.create(:converter)
        posting = for_test 1, {source: converter.source}
        posting.delete(:state)
        res = converter.convert(posting, processor)
        expect(res[:posting_state]).to eq("available")
      end

      it 'when posting come without flagged_status, flagged_status should be' do
        converter = FactoryGirl.create(:converter)
        posting = for_test 1, {source: converter.source}
        posting.delete(:flagged_status)
        res = converter.convert(posting, processor)
        expect(res[:flagged_status]).to eq(0)
      end

      context 'geolocation status' do
        before do
          @converter = FactoryGirl.create(:converter)
          @posting1 = for_test 1, { source: @converter.source, location: { zipcode: '501' } }
          @posting2 = for_test 1, { source: @converter.source, location: { zipcode: 501 } }
        end

        it 'for string zipcode should be valid' do
          res = @converter.convert(@posting1, processor)
          expect(res[:geolocation_status]).to eq(1)
        end

        it 'for integer zipcode should be valid' do
          res = @converter.convert(@posting2, processor)
          expect(res[:geolocation_status]).to eq(1)
        end
      end
    end
  end
end
