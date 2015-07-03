module PostingValidation
  def field_types_validation
    annotations_validation
    images_validation
    boolean_fields_validation
    before_type_cast_validation
    location_validation
  end

  def before_type_cast_validation
    self.errors.add(:timestamp, 'should be an integer value') if timestamp_before_type_cast && !can_be_converted_to_integer?(timestamp_before_type_cast)
    self.errors.add(:expires, 'should be an integer value') if expires_before_type_cast && !can_be_converted_to_integer?(expires_before_type_cast)
    self.errors.add(:price, 'should be a float value') if price_before_type_cast && !can_be_converted_to_float?(price_before_type_cast)
  end

  def annotations_validation
    return unless annotations
    self.errors.add(:annotations, 'should be an object') and return unless annotations.is_a?(Hash)
    annotations.each do |attribute, value|
      self.errors.add(:annotations, "attribute #{attribute} should be a string") unless value.is_a?(String)
    end
  end

  def images_validation
    return unless images
    self.errors.add(:images, 'should be an array') and return unless images.is_a?(Array)
    images.each_with_index do |image, index|
      self.errors.add(:images, "#{index} should be an object") and next unless image.is_a?(Hash)
      [:full_width, :full_height, :thumbnail_width, :thumbnail_height].each do |attribute|
        self.errors.add(:images, "#{index} #{attribute} should be an integer value") if image[attribute] && !can_be_converted_to_integer?(image[attribute])
      end
    end
  end

  def boolean_fields_validation
    [:immortal, :deleted, :flagged].each do |field|
      if boolean_field_has_wrong_value?(send("#{field.to_s}_before_type_cast"))
        self.errors.add(field, 'should be a boolean value')
      end
    end
  end

  def location_validation
    return unless location
    self.errors.add(:location, 'should be an object') and return unless location.is_a?(Hash)

    [:lat, :long].each do |field|
      self.errors.add(:location, "#{field} should be a float value") if location[field] && !can_be_converted_to_float?(location[field])
    end
    self.errors.add(:location, 'accuracy should be an integer value') if location[:accuracy] && !can_be_converted_to_integer?(location[:accuracy])

    bounds_validation
    coordinates_validation
  end

  def bounds_validation
    return if location[:bounds].nil?
    self.errors.add(:location, 'bounds should be an array') and return unless location[:bounds].is_a?(Array)
    self.errors.add(:location, 'bounds should have 4 values') if location[:bounds].size != 4
    location[:bounds].each_with_index do |bound, index|
      self.errors.add(:location, "bound #{index} should be a float value") if !can_be_converted_to_float?(bound)
    end
  end

  def coordinates_validation
    lat = typecasted_coordinate('lat', location[:lat])
    long = typecasted_coordinate('long', location[:long])
    check_coordinate('latitude', lat, -90, 90)
    check_coordinate('longitude', long, -180, 180)

    return if location[:bounds].nil? || errors[:location].include?('bounds should be an array')
    min_lat = typecasted_coordinate('bound 0', location[:bounds][0])
    max_lat = typecasted_coordinate('bound 1', location[:bounds][1])
    min_long = typecasted_coordinate('bound 2', location[:bounds][2])
    max_long = typecasted_coordinate('bound 3', location[:bounds][3])

    check_coordinate('min latitude', min_lat, -90, 90)
    check_coordinate('max latitude', max_lat, -90, 90)
    check_coordinate('min longitude', min_long, -180, 180)
    check_coordinate('max longitude', max_long, -180, 180)
  end

  def typecasted_coordinate(name, value)
    !errors[:location].include?("#{name} should be a float value") && value.to_f
  end

  def check_coordinate(name, value, left_border, right_border)
    errors.add(:location, "#{name} should be in range #{left_border}..#{right_border}") if value && (value < left_border || value > right_border)
  end

  def boolean_field_has_wrong_value?(field)
    !(field.nil? || field == 'true' || field == 'false' || field == true || field == false)
  end

  def can_be_converted_to_integer?(string)
    string.to_s.match(/\A-?\d+\z/)
  end

  def can_be_converted_to_float?(string)
    string.to_s.match(/\A-?(\d+)(\.)?(\d+)?\z/)
  end
end