class PollingPatterns
  def self.track(params)
    anchor = params['anchor']
    pattern = PollingPattern.from_params params

    return if pattern.pattern_keys.blank? or not pattern.is_uniq?

    requested_volume = "postings#{ Posting2.volume_by_id(anchor) }"
    current_volume = "postings#{Posting2.current_volume}"

    pattern.save unless index_exists?(requested_volume, pattern)

    unless index_exists?(current_volume, pattern)
      NotificationMailer.unknown_polling_pattern(pattern, "#{current_volume} (current volume) is not optimized for polling").deliver!
    end

    unless index_exists?(requested_volume, pattern)
      NotificationMailer.unknown_polling_pattern(pattern, "#{requested_volume} is not optimized for polling").deliver!
    end
  end

  protected

  def self.index_exists?(table_name, pattern)
    indexes = ActiveRecord::Base.connection.indexes(table_name).map { |i| i.columns }
    array_includes?(indexes, pattern.pattern_keys)
  end

  def self.arrays_equal?(a, b)
    a.sort == b.sort
  end

  def self.array_includes?(haystack, needle)
    not (haystack.select { |k| arrays_equal?(k, needle) }).empty?
  end
end
