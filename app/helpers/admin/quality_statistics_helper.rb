module Admin::QualityStatisticsHelper
  def missing_and_exceeding_annotations_of(posting)
    required = CalculateAnnotation.where(source: posting[:source], category: posting[:category]).pluck(:annotation)
    present = (posting[:annotations] || {}).keys

    missing = required - present
    exceeding = present - required

    [ missing, exceeding ]
  end

  def missing_fields_of(posting)
    required = %w(category category_group source formatted_address phone external_id external_url heading body html price expires currency images status timestamp posting_state flagged_status origin_ip_address)
    present = posting.attributes.select { |_, v| v.present? }.keys

    missing = required - present

    missing << 'source_account' if (not posting.respond_to?(:annotations)) or posting[:annotations].blank? or posting[:annotations][:source_account].blank?

    if posting.respond_to?(:accuracy) and (posting[:accuracy].blank? or posting[:accuracy].to_i < 8)
      missing << "accuracy (#{ posting[:accuracy] })"
    else
      missing << "accuracy"
    end

    missing
  end
end
