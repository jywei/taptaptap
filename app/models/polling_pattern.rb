class PollingPattern < ActiveRecord::Base
  SKIP_PARAMS = %w(anchor auth_token controller action rpp retvals)

  serialize :request_params, Array
  serialize :pattern_keys, Array

  def is_uniq?
    @is_uniq ||= (PollingPattern.where('pattern_keys = ?', pattern_keys.to_yaml).blank?)
  end

  def self.from_params(params)
    request_params = params.keys
    pattern_keys = params.keys.reject { |k| SKIP_PARAMS.include? k.to_s }
    pattern_keys.map! { |k| k.gsub /^location\./, '' }.sort!

    PollingPattern.new request_params: request_params, pattern_keys: pattern_keys
  end
end
