
require 'rails/generators/active_record'

class CustomTableGenerator < ActiveRecord::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path("templates", __dir__)

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/custom_table.rb"
  end

  def copy_migration_file
    migration_template "migration.rb", "db/migrate/add_custom_table_to_users.rb"
  end

end
