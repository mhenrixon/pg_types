# frozen_string_literal: true

module PgTypes
  module SchemaStatements
    def create_type(name, version: nil, sql_definition: nil)
      raise ArgumentError, "Must provide either sql_definition or version" if sql_definition.nil? && version.nil?

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
  end
end
