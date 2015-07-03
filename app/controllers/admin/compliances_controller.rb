require 'csv'

class Admin::CompliancesController < Admin::ApplicationController
  add_breadcrumb :compliances_manager, :admin_compliances_path
  POSTING_FIELDS = %w(annotations source category category_group external_id external_url heading body html timestamp expires language price currency images images_full images_full_width images_full_height images_thumbnail images_thumbnail_width images_thumbnail_height status flagged deleted immortal lat long accuracy min_lat max_lat min_long max_long country state metro region county city locality zipcode formatted_address)

  def index
    flash.clear()
    @example = PostingExample.find(params[:posting_example_id]) if params[:posting_example_id].present?

    if params['commit'] == 'Assign'
      @example.source_code = params[:source_code]
      @example.save!
    end

    @handled_fields = {}
    if params['commit'] == 'Save'
      @fields = params[:fields]
      @ruby_code = params[:ruby_code]
      if @example.source_code
        annotations = []
        @fields.each do |key,field_data|
          if field_data['field'] == 'annotations'
            annotations << [field_data['annotation_key'].gsub('"',''),field_data['key']].join(',')
          elsif POSTING_FIELDS.include?(field_data['field'])
            @handled_fields[field_data['field']] = field_data['key']
          end
        end
        @handled_fields['annotations'] = annotations.join('|')

        CSV.open("#{Rails.root}/lib/data/#{@example.source_code}_parsing_configuration.csv", "wb") do |config|
          POSTING_FIELDS.each do |field|
            config << [field,@handled_fields[field],nil,@ruby_code[field]]
          end
        end

        flash[:notice] = 'successfully saved'
      else
        flash[:notice] = 'wasn\'t saved, source code is absent'
      end
    end

    unordered_json = @example.posting.is_a?(Array) ? @example.posting[0] : @example.posting if @example

    @json = {}
    unordered_json.keys.sort.each do |key|
      @json[key] = unordered_json[key]
      @json = fit_subhashes_in_parent_hash(@json, key, @json[key]) if @json[key].is_a? Hash
    end if unordered_json.present?
  end

  private

  def order_hash_by_key(unordered_hash)
    ordered_hash = {}
    unordered_hash.keys.sort.each do |key|
      ordered_hash[key] = unordered_hash[key]
    end
    ordered_hash
  end

  def fit_subhashes_in_parent_hash(hash, key, value_hash)
    value_hash = order_hash_by_key(value_hash)
    value_hash.each do |k,v|
      hash["#{key}>>#{k}"] = v
      hash = fit_subhashes_in_parent_hash(hash, "#{key}>>#{k}", v) if v.is_a? Hash
    end
    hash
  end
end
