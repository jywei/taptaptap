class AnnotationsController < ApplicationController
  include ApplicationHelper

  after_filter :cors_set_access_control_headers

  def index
    render json: { errors: ["auth_token is absent"] }.to_json and return unless params[:auth_token].present?

    filter_annotations

    render json: annotations_response_format.to_json
  end

  protected

  def filter_by(filter_key, &block)
    return if @filters[filter_key].blank?

    @annotations.select! do |annotation|
      if block_given?
        block.call(annotation)
      else
        not (annotation[filter_key] & @filters[filter_key].split(',')).empty?
      end
    end
  end

  def annotations_response_format
    results = @annotations.map do |annotation|
      next unless annotation.public?

      result = {
          name: annotation.name,
          sources: annotation.sources,
          categories: annotation.categories,
          category_groups: annotation.category_groups,
          control_type: annotation.control_type,
          sent_as_annotation: annotation.sent_as_annotation?,
          options: annotation.renderable_options
      }

      result[:all_sources] = annotation.all_sources? if annotation.all_sources?
      result[:all_categories] = annotation.all_categories? if annotation.all_categories?
      result[:all_category_groups] = annotation.all_category_groups? if annotation.all_category_groups?
      result[:all_categories_in_group] = annotation.all_categories_in_group? if annotation.all_categories_in_group?

      result
    end

    results.compact
  end

  def filter_annotations
    @annotations = Annotation.all.to_a
    @filters = params.dup

    filter_by(:sources)
    filter_by(:category_groups)
    filter_by(:categories)
  end

end
