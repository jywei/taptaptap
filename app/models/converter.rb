# Converter logic:
#   list of accepted values is accepted;
#   if convert is true then other values are substituted with default value
#   if there is a list of rejected values they are sent back as errors.
#   I.e. finally rejected values are rejected, accepted are accepted, others are
#      converted to default values if convert is set to true
#

class Converter < ActiveRecord::Base
  FIELDS_AVAILABLE_FOR_CONVERTATION = [
      :category, :category_group, :status, :state, :flagged_status
  ]

  FIELDS_WITH_DEFAULT_VALUES = [
      :state, :status, :flagged_status
  ]

  include Converters::Geolocation
  include Converters::Default

  serialize :reject_status, Array
  serialize :accept_status, Array
  serialize :convert_status_values, Array
  serialize :accept_flagged_status, Array
  serialize :reject_flagged_status, Array
  serialize :convert_flagged_status_values, Array
  serialize :reject_state, Array
  serialize :accept_state, Array
  serialize :convert_state_values, Array
  serialize :reject_category, Array
  serialize :accept_category, Array
  serialize :reject_category_group, Array
  serialize :accept_category_group, Array
  #validates :source, uniqueness: true

  def convert(posting, data_converter)
    @posting = posting
    @data_converter = data_converter

    category_group

    _flagged_status

    FIELDS_AVAILABLE_FOR_CONVERTATION.each do |f|
      if FIELDS_WITH_DEFAULT_VALUES.include?(f) and convert_value?(f)
        # if convert flag is set - update value
        posting_update_value(f)
      end

      # if flag to reject only specific values is true
      if reject_values_for(f) and rejected_values_for(f).include? posting_value(f)
        #SULO6.error "reject filter, call by method: #{posting_value(f)}"
        #SULO6.error "reject filter, call by hash index category group: #{@posting[:category_group]}"

        add_error f, "[rejector] wrong #{f}: `#{posting_value(f).inspect}`"
      end

      # if flag to accept only specific values is true
      if accept_values_for(f)
        # if the value is not in list - send back an error
        unless accepted_values_for(f).include? posting_value(f)
          #SULO6.error "accept filter, call by method: #{posting_value(f)}"
          #SULO6.error "accept filter, call by hash index category group: #{@posting[:category_group]}"

          add_error f, "[acceptor] wrong #{f}: `#{posting_value(f).inspect}`"
        end
      end
    end

    # default fields
    _status
    _state
    location
    annotations
    images

    accuracy
    geolocation_status

    @posting.to_hash.symbolize_keys
  end

  private

  def use_default_logic?(f)
    self.send("use_default_#{f}_logic")
  end

  def value(f)
    self.send(f)
  end

  def convert_value?(f)
    self.send("convert_#{f}") && self.send("convert_#{f}_values").include?(posting_value(f))
  end

  def wrong_values_for(f)
    filter_value_list self.send("#{f}_wrong_values")
  end

  def accepted_values_for(f)
    filter_value_list self.send("accept_#{f}")
  end

  def rejected_values_for(f)
    filter_value_list self.send("reject_#{f}")
  end

  def accept_values_for(f)
    self.send("use_accept_#{f}")
  end

  def reject_values_for(f)
    self.send("use_reject_#{f}")
  end

  def posting_value(f)
    @posting[f]
  end

  def posting_update_value(f)
    @posting[f] = self.send(f)
  end

  def add_error(f, v)
    @data_converter.send(:add_error, f, v)
  end

  def add_warning(f, v)
    @data_converter.send(:add_warning, f, v)
  end

  def filter_value_list(v)
    v.is_a?(Array) ? v : v.split(',').map(&:strip)
  end
end
