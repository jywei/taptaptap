class LatencyReport
  def self.run
    volume = 1612

    PostingConstants::SOURCES.each do |source|
      query = <<-SQL
        drop table if exists tmp_latencies_#{ source.downcase };
      SQL

      Posting2.connection.query query

      query = <<-SQL
        drop table if exists tmp_latencies_grouped_for_#{ source.downcase };
      SQL

      Posting2.connection.query query

      query = <<-SQL
        create table if not exists tmp_latencies_#{ source.downcase } as
        (
            select
                id,
                source,
                abs(timestampdiff(second, created_at, from_unixtime(timestamp))) - (5 * 60 * 60) as latency
            from postings#{ volume }
            where source = '#{ source }'
        );
      SQL

      # create table with latencies for current source
      Posting2.connection.query query

      ranges = []

      max_range = 5000
      step_size = 500
      endless = 5_000_000

      0.step(max_range - step_size, step_size) do |i|
        ranges << "select #{ i } as startrange, #{ i + step_size - 1} as endrange"
      end

      ranges << "select #{ max_range } as startrange, #{ endless } as endrange"

      # create temporary table for results
      query = <<-SQL
        create table if not exists tmp_latencies_grouped_for_#{ source.downcase } as
        (
            select
                startrange,
                endrange,
                count(A.id) as postings
            from
            (
                #{ ranges.join ("\nunion all\n") }
            ) as Ranges
            join tmp_latencies_#{ source.downcase } as A on (A.latency between Ranges.startrange AND Ranges.endrange)
            group by Ranges.startrange, Ranges.endrange
        )
      SQL

      Posting2.connection.query(query)

      # select all the data for report
      query = <<-SQL
        select
            startrange,
            endrange,
            postings,
            round(postings / (select sum(postings) from tmp_latencies_grouped_for_#{ source.downcase }) * 100.0, 4) as percentage
        from tmp_latencies_grouped_for_#{ source.downcase }
        group by startrange, endrange, postings
        order by percentage desc
      SQL

      # select latencies with percentage
      rows = Posting2.connection.query(query).to_a

      vars = {rows: rows}

      template = File.read(File.join(Rails.root, %w(lib latency_report latency_report.xls.erb)))
      output_file = File.join(Rails.root, 'tmp', "latency_report_#{source.downcase}.xls")
      output_content = ERB.new(template).result(OpenStruct.new(vars).instance_eval { binding })

      File.write(output_file, output_content)
    end
  end
end