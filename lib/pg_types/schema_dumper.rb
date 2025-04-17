# frozen_string_literal: true

module PgTypes
  module SchemaDumper
    # Define a Struct for type information
    TypeDefinition = Struct.new(:name, :definition)

    # Override the types method from ActiveRecord's PostgreSQL schema dumper
    # This will run at the right time in the schema dump process (after extensions, before tables)
    def tables(stream)
      # Then add our custom composite types
      dump_custom_types(stream)

      # Call the original types method first (for enum types)
      super
    end

    private

    def dump_custom_types(stream)
      types = dumpable_types_in_database

      return if types.empty?

      stream.puts "  # These are custom PostgreSQL types that were defined"

      # Sort by name to ensure consistent ordering
      types.sort_by(&:name).each do |type|
        stream.puts <<-TYPE
    create_type "#{type.name}", sql_definition: <<-SQL
      #{type.definition}
    SQL
        TYPE
      end
    end

    # Fetches all custom types from the database
    def dumpable_types_in_database
      @dumpable_types_in_database ||= begin
        # SQL query to fetch custom types from PostgreSQL
        sql = <<~SQL
          SELECT#{" "}
            t.typname AS name,
            format(
              'CREATE TYPE %s AS (%s);',
              t.typname,
              array_to_string(
                array_agg(
                  format(
                    '%s %s',
                    a.attname,
                    pg_catalog.format_type(a.atttypid, a.atttypmod)
                  ) ORDER BY a.attnum
                ),
                E',\n        '
              )
            ) AS definition
          FROM pg_type t
          JOIN pg_class c ON (c.relname = t.typname)
          JOIN pg_attribute a ON (a.attrelid = c.oid)
          JOIN pg_namespace n ON (n.oid = t.typnamespace)
          WHERE n.nspname = 'public'
            AND c.relkind = 'c'
            AND a.attnum > 0
            AND NOT a.attisdropped
          GROUP BY t.typname, n.nspname
          ORDER BY t.typname;
        SQL

        # Get the appropriate connection
        connection = ActiveRecord::Base.connection

        # Execute the query and transform results into type objects
        connection.execute(sql).map do |result|
          TypeDefinition.new(
            result["name"],
            result["definition"].strip
          )
        end
      end
    end
  end
end
