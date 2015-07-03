# FirstVolume.create(volume: 0) if FirstVolume.first_volume.nil?
# LastVolume.create(volume: 0) if LastVolume.last_volume.nil?

sources = Converter.pluck(:source)

default_options = {
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

options = {
  EBAYM: default_options.merge({convert_status: true, status: 'for_sale', convert_status_values: ["offered"], use_accept_category_group: true, accept_category_group: ["VVVV"]}),
  BKPGE: default_options,
  OODLE: default_options,
  INDEE: default_options,
  HMNGS: default_options,
  APTSD: default_options,
  CARSD: default_options,
  CCARS: default_options,
  AUTOD: default_options,
  AUTOC: default_options,
  RENTD: default_options,
  E_BAY: default_options,
  DRVAU: default_options,
  CARAU: default_options,
  DOMAU: default_options,
  RESTT: default_options,
  all:   default_options.merge({use_geolocation_module: false})
}

options.keys.each do |key|
  if sources.include? key.to_s
    c = Converter.where(source: key).first
    c.update_attributes(options[key])
  else
    Converter.create options[key].merge({source: key})
  end
end
