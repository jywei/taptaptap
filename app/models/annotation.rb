class Annotation < ActiveRecord::Base
  QUEUE_NAME = 'posting_annotations'
  PROCESSING_ENABLED = false

  CONTROL_TYPES = %w(text select multiselect checkbox range)
  OVERRIDE_VALUES = { 'yes' => true, 'no' => false }
  ALLOWED_OPTIONS = %w(status phone price bedrooms sqft cats dogs make model vin year age personal_flavor compensation part_time telecommute contract internship nonprofit)

  serialize :sources, Array
  serialize :categories, Array
  serialize :category_groups, Array
  serialize :options, Array
  serialize :public_options, Array

  validates :control_type, :inclusion => { :in => CONTROL_TYPES }

  def public?
    self.is_public || true
  end

  def sent_as_annotation?
    self.sent_as_annotation
  end

  def renderable_options
    if self.public_options.present?
      self.public_options
    else
      self.options
    end
  end

  def all_sources?
    if self.override_all_sources_value.present?
      self.override_all_sources_value
    else
      self.sources.sort.map(&:to_s) == PostingConstants::SOURCES.sort.map(&:to_s)
    end
  end

  def all_categories?
    if self.override_all_categories_value.present?
      self.override_all_categories_value
    else
      self.categories.sort.map(&:to_s) == PostingConstants::CATEGORIES.sort.map(&:to_s)
    end
  end

  def all_category_groups?
    if self.override_all_category_groups_value.present?
      self.override_all_category_groups_value
    else
      self.category_groups && (self.category_groups.sort.map(&:to_s) == PostingConstants::CATEGORY_GROUPS.sort.map(&:to_s))
    end
  end

  def all_categories_in_group?
    if self.override_all_categories_in_group_value.present?
      self.override_all_categories_in_group_value
    else
      # TODO: rework
      false
    end
  end
end
