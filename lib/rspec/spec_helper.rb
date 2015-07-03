require "spec_helper"

module SpecHelper
  def env_for_strong_params(raw_parameters)
    parameters = ActionController::Parameters.new(raw_parameters)
    controller.params = parameters
  end

  def stub_hash_from_array(array_parameters)
    Hash[array_parameters.zip ['stub_value']*array_parameters.length]
  end

  def posting_environment_helpers
    let(:common_posting) do
      posting = FactoryGirl.build(:posting)
      posting.save!(validate: false)
      posting
    end

    let(:location) { FactoryGirl.create(:location) }
  end

  def build_posting(params)
    posting = FactoryGirl.build(:posting, params)
    posting.save
    posting
  end
end
