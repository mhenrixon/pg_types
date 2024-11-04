# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module Pg
  module Generators
    class TypeGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      class_option :version,
                   type: :string,
                   default: "1",
                   desc: "Specify a version for the type"

      class_option :fields,
                   type: :array,
                   default: [],
                   desc: "Fields for composite type (e.g. name:text active:boolean)"

      def create_type_file
        @version = options[:version]
        @type_name = file_name
        @fields = parse_fields(options[:fields])

        template(
          "type.sql.erb",
          "db/types/#{file_name}_v#{@version}.sql"
        )
      end

      def create_migration_file
        @version = options[:version]
        @type_name = file_name
        @migration_version = migration_version

        migration_template(
          "migration.rb.erb",
          "db/migrate/create_type_#{file_name}.rb"
        )
      end

      private

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
      end

      def parse_fields(fields)
        fields.map do |field|
          name, type = field.split(":")
          { name: name, type: type || "text" }
        end
      end
    end
  end
end
