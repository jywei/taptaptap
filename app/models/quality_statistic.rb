class QualityStatistic
  def self.track(postings, type)
    quantities = {}

    postings.each do |posting|
      next unless posting[:quality].present?

      key = "'#{posting[:source]}','#{posting[:created_at].strftime("%Y-%m-%d")}','#{posting[:transit_ip_address]}','#{posting[:quality]}'"
      quantities.has_key?(key) ? quantities[key] += 1 : quantities[key] = 1
    end

    if quantities.present?
      values = quantities.map { |keys, q|  "(#{ keys }, #{ q },'#{ Time.now.utc.to_s(:db) }')" }.join ','
      model = "StatisticBy#{type.to_s.capitalize}Quality".constantize
      model.connection.execute("INSERT INTO statistic_by_#{ type }_qualities (source, for_date, transit_ip_address, quality, quantity, created_at) VALUES #{ values } ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity), updated_at = VALUES(created_at)")
    end
  end

  def self.qualities(type, start_date, end_date, parts)
    partitions = create_partitions(parts.dup)

    by_sources = get_quality(type, "source", start_date, end_date, partitions)
    by_ips = get_quality(type, "transit_ip_address", start_date, end_date, partitions)

    {
      by_sources: by_sources,
      by_ips: by_ips,
      total: [{ name: "total", data: by_sources.map {|q| [ q[:name], q[:data].map {|e| e.last}.sum ] } }]
    }
  end

  private

  def self.get_quality(type, field, start_date, end_date, partitions)
    table_name = "statistic_by_#{ type.downcase }_qualities"

    model = "StatisticBy#{ type.camelize }Quality".constantize
    empties = (field == "source") ? Posting::SOURCES : model.uniq.pluck(:transit_ip_address)

    dates = start_date.to_s(:db) .. end_date.to_s(:db)

    partitions.map do |partition|
      title = partition.size > 1 ? "#{partition.first}-#{partition.last}%" : "#{partition.first}%"

      query = <<-SQL
        SELECT
          #{ field }, SUM(quantity) AS quantity
        FROM
          #{ table_name }
        WHERE
          (for_date BETWEEN '#{ start_date.to_s(:db) }' AND '#{ end_date.to_s(:db) }') AND
          (quality BETWEEN #{ partition.first } AND #{ partition.last })
        GROUP BY
          #{ field }
      SQL

      # a = model.connection.execute(query).to_a
      # b = model.select("#{field}, sum(quantity) AS quantity").where(for_date: dates, quality: partition.first .. partition.last).group(field.to_sym)
      # c = model.where(for_date: dates, quality: partition.first .. partition.last).group(field.to_sym).pluck("#{field}, sum(quantity) AS quantity")

      res = model.connection.execute(query).to_a
      res += (empties - res.map(&:first)).map{|empty| [empty, 0]}
      res.sort_by!{|e| e.first}

      {
        name: title,
        data: res
      }
    end
  end

  def self.create_partitions(parts)
    if parts.present?
      res = nil

      if parts.has_key?(:start_q) && parts.has_key?(:end_q)
        parts[:start_q] = 0 if parts[:start_q] < 0
        parts[:end_q] = 100 if parts[:end_q] > 100
        res = parts[:start_q]..parts[:end_q]
      elsif parts.has_key?(:start_q)
        parts[:start_q] = 0 if parts[:start_q] < 0
        parts[:start_q] = 100 if parts[:start_q] > 100
        res = parts[:start_q]..100
      else
        parts[:end_q] = 0 if parts[:end_q] < 0
        parts[:end_q] = 100 if parts[:end_q] > 100
        res = 0..parts[:end_q]
      end
      res = res.to_a
      if res.size < 3
        if res.last < 100
          res << res.last + 1
        elsif res.first > 0
          res.unshift res.first - 1
        end
      end
      res.in_groups(3, false).map {|e| [e.first, e.last].uniq unless e.empty?}.compact
    else
      [ [0, 59], [60, 89], [90, 100] ]
    end
  end
end
