# frozen_string_literal: true

module PgTypes
  module SchemaStatements
    def create_type(name, version: nil, sql_definition: nil)
      raise ArgumentError, "Must provide either sql_definition or version" if sql_definition.nil? && version.nil?

      # First, check if the type already exists to avoid duplicate creation attempts
      return if type_exists?(name)

      if sql_definition
        execute sql_definition
      else
        # Try both Rails.root and current directory for type definition
        type_definition = PgTypes::TypeDefinition.new(name, version: version)
        paths = [
          type_definition.path,
          File.join(Dir.pwd, "db", "types", "#{name}_v#{version}.sql")
        ]

        sql_file = paths.find { |path| File.exist?(path) }

        raise ArgumentError, "Could not find type definition file in paths: #{paths.join(", ")}" unless sql_file

        execute File.read(sql_file)
      end
    rescue ActiveRecord::StatementInvalid => e
      puts "WARNING: Failed to create type #{name}."
      puts "         Error: #{e.message}"
      raise
    end

    def drop_type(name, force: false)
      force_clause = force ? " CASCADE" : ""
      # Drop the type and any dependent objects when force: true
      execute "DROP TYPE IF EXISTS #{name}#{force_clause}"

      # Ensure any dependent objects are really gone when using CASCADE
      return unless force

      execute <<-SQL
          DO $$
          BEGIN
            EXECUTE format('DROP TABLE IF EXISTS %I CASCADE', 'test_contacts');
          END;
          $$;
      SQL
    end

    private

    def type_exists?(name)
      sql = <<-SQL
        SELECT 1
        FROM pg_catalog.pg_type t
        JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
        WHERE t.typname = '#{name}'
        AND n.nspname = 'public'
      SQL

      result = execute(sql)
      result.any?
    rescue StandardError
      false
    end
  end
end
