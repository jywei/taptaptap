require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record/migration/migration_generator'

class MigrationStatGenerator < ActiveRecord::Generators::MigrationGenerator
  source_root File.join(File.dirname(__FILE__), 'templates')

  def create_migration_file
    set_local_assigns!
    validate_file_name!
    migration_template @migration_template, "db/migrate_stat/#{file_name}.rb"
  end

  protected

  def set_local_assigns!
    @migration_template = "migration.rb.erb"
    case file_name
      when /^(add|remove)_.*_(?:to|from)_(.*)/
        @migration_action = $1
        @table_name       = $2.pluralize
      when /join_table/
        if attributes.length == 2
          @migration_action = 'join'
          @join_tables      = attributes.map(&:plural_name)

          set_index_names
        end
      when /^create_(.+)/
        @table_name = $1.pluralize
        @migration_template = "create_table_migration.rb.erb"
    end
  end
end
