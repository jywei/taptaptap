class AnnotationsCoder
  MAGIC_DUMP_VOLUME = if Rails.env.production?
                        1419
                      elsif Rails.env.staging?
                        22
                      else
                        Posting2.current_volume - 1
                      end

  def self.dump(data, volume = Posting2.current_volume)
    if volume > MAGIC_DUMP_VOLUME
      Oj.dump(data)
    else
      YAML.dump(data)
    end
  end

  def self.load(data, volume = Posting2.current_volume)
    if volume > MAGIC_DUMP_VOLUME
      Oj.load(data)
    else
      YAML.load(data)
    end
  end
end