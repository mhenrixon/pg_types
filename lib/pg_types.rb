# frozen_string_literal: true

require "active_record/railtie"

require_relative "pg_types/file_version"
require_relative "pg_types/type_definition"
require_relative "pg_types/schema_statements"
require_relative "pg_types/command_recorder"
require_relative "pg_types/schema_dumper"
require_relative "pg_types/railtie"

module PgTypes
  module_function

  class Error < StandardError; end

  def load
    # Add schema statements and command recorder
    ActiveRecord::ConnectionAdapters::AbstractAdapter.include PgTypes::SchemaStatements
    ActiveRecord::Migration::CommandRecorder.include PgTypes::CommandRecorder

    # Hook into the schema dumper
    ActiveRecord::SchemaDumper.prepend PgTypes::SchemaDumper
  end

  def database
    ActiveRecord::Base.connection
  end
end
