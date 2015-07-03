class AddAustralianConverters < ActiveRecord::Migration
  DEFAULT_OPTIONS = {
      use_accept_status: false,
      convert_status: false,
      use_reject_status: false,

      use_accept_state: false,
      convert_state: false,
      use_reject_state: false,

      use_accept_flagged_status: false,
      convert_flagged_status: false,
      use_reject_flagged_status: false,

      use_accept_category_group: false,
      use_reject_category_group: false,

      use_geolocation_module: true
  }

  CONVERTERS = {
      DRVAU: DEFAULT_OPTIONS,
      CARAU: DEFAULT_OPTIONS,
      DOMAU: DEFAULT_OPTIONS,
      RESTT: DEFAULT_OPTIONS
  }

  def up
    CONVERTERS.each do |key, value|
      Converter.create value.merge({source: key})
    end
  end

  def down
    CONVERTERS.keys.each do |key|
      Converter.where(source: key).destroy_all
    end
  end
end
