class AverageQuality < StatisticBase
  def self.flush_to_db(for_date = Date.today)
    ([ 'total' ] + PostingConstants::SOURCES).each do |source|
      q = <<-SQL
          SELECT
              '#{ source }' AS source,
              annotations_quality,
              fields_quality,
              SUM(s.count) AS postings
          FROM
              (
                  SELECT
                      ROUND(SUM(a.quality * a.quantity) / SUM(a.quantity), 2) AS annotations_quality,
                      ROUND(SUM(f.quality * f.quantity) / SUM(f.quantity), 2) AS fields_quality,
                      a.for_date
                  FROM
                      statistic_by_annotations_qualities AS a
                  LEFT JOIN
                      statistic_by_fields_qualities AS f
                  ON
                      (a.source = f.source AND a.for_date = f.for_date)
                  WHERE
                      a.for_date = '#{ for_date }' AND #{ source == 'total' ? " a.source IS NOT NULL " : " a.source = '#{ source }' " }
              ) AS t1
          LEFT JOIN
              statistic_by_sources AS s
          ON
              t1.for_date = s.for_date AND #{ source == 'total' ? " s.source IS NOT NULL " : " s.source = '#{ source }' " }
      SQL

      attributes = connection.select_all(q).to_a.first

      next unless attributes

      row = find_or_create_by(source: source, for_date: for_date)
      row.update_attributes(attributes)
    end
  end

  def self.combinated_data(start_date, end_date, source)
    flush_to_db

    q = <<-SQL
        SELECT
            *
        FROM
            average_qualities AS a
        WHERE
            for_date BETWEEN '#{ start_date }' AND '#{ end_date }' AND source = '#{ source }'
    SQL

    connection.select_all(q).to_a
  end
end
