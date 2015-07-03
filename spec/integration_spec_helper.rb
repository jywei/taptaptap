require 'spec_helper'
require 'timeout'

class IntegrationSpecHelper
  VOLUME_AMOUNT = 3

  def initialize
    @connection ||= Mysql2::Client.new(
        { host: 'localhost' }.merge(ActiveRecord::Base.connection_config).except(:adapter)
    )

    @values = {}

    get_volumes
  end

  def seed_database
    # copy last VOLUME_AMOUNT posting volumes (except the last one) to the test' DB
    config_names = %w(production staging development)

    begin
      config_name = config_names.shift
      prod_db_config = Rails.configuration.database_configuration[config_name]
      db_name = prod_db_config['database']

      queries = []

      @volumes.each do |volume_name|
        src_table_name = "#{ db_name }.#{ volume_name }"
        dst_table_name = volume_name

        queries += [
            "DROP TABLE IF EXISTS #{ dst_table_name };",
            "CREATE TABLE #{ dst_table_name } LIKE #{ src_table_name };",
            "INSERT INTO #{ dst_table_name } SELECT * FROM #{ src_table_name };"
        ]
      end

      queries.each { |q| @connection.query q }

      # set volumes
      queries = [
          "REPLACE first_volume SET volume = #{ @first_volume };",
          "REPLACE current_volume SET volume = #{ @last_volume };",
          "REPLACE last_volume SET volume = #{ @last_volume };",
          "DELETE FROM recent_anchors WHERE 1 = 1;"
      ]

      queries.each { |q| @connection.query q }
    rescue
      retry unless config_names.empty?
    end
  end

  def get_column_values(column)
    if @values[column].blank?
      # find the lower bound anchor for all the selects
      values = []

      @first_volume.upto(@last_volume) do |volume|
        tmp = @connection.query("SELECT DISTINCT #{ column } AS value FROM postings#{ volume }").to_a.map { |e| e['value'] }
        values.concat tmp
      end

      @values[column] = values.uniq.reject { |e| e.blank? }
    end

    @values[column]
  end

  def anchors
    @anchors ||= get_anchors
  end

  def sources
    get_column_values('source')
  end

  def cities
    get_column_values('city')
  end

  def metro_stations
    get_column_values('metro')
  end

  def category_groups
    get_column_values('category_group')
  end

  def categories
    get_column_values('category')
  end

  def statuses
    get_column_values('status')
  end

  protected

  def get_volumes
    config_names = %w(production staging development)

    begin
      config_name = config_names.shift

      prod_db_config = Rails.configuration.database_configuration[config_name]

      prod_connection = Mysql2::Client.new(
          { host: 'localhost' }.merge(prod_db_config).except(:adapter)
      )
    rescue
      retry unless config_names.empty?
    end

    tables = prod_connection.query("SHOW TABLES LIKE 'postings%'").to_a.map { |e| e.values }.flatten
    @volumes = tables.select { |t| t =~ /postings\d+/ }.reverse.first(VOLUME_AMOUNT + 1).drop(1).reverse

    @first_volume = @volumes.first.match(/postings(\d+)/)[1]
    @last_volume = @volumes.last.match(/postings(\d+)/)[1]
  end

  def get_anchors
    # find the lower bound anchor for all the selects
    anchors = []

    @first_volume.upto(@last_volume) do |volume|
      anchors << @connection.query("SELECT MIN(id) AS anchor FROM postings#{ volume }").to_a.first['anchor']
    end

    anchors
  end
end
