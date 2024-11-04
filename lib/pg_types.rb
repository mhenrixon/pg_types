# frozen_string_literal: true

require "active_record/railtie"

require_relative "pg_types/file_version"
require_relative "pg_types/type_definition"
require_relative "pg_types/schema_statements"
require_relative "pg_types/command_recorder"
require_relative "pg_types/schema_dumper"
require_relative "pg_types/railtie"

module PgTypes
  class Error < StandardError; end

  class << self
    def database
      ActiveRecord::Base.connection
    end
  end
end
