# frozen_string_literal: true

module PgTypes
  module SchemaDumper
    def tables(stream)
      # First dump types
      dump_custom_types(stream)
      stream.puts

      super
    end

    private

    def dump_custom_types(stream)
      type_versions = {}
      Dir.glob(File.join(Dir.pwd, "db/types/*_v*.sql")).each do |file|
        file_version = FileVersion.new(file)
        type_versions[file_version.name] ||= []
        type_versions[file_version.name] << file_version
      end

      return if type_versions.empty?

      stream.puts "  # These are custom PostgreSQL types that were defined"

      latest_versions = type_versions.transform_values do |versions|
        versions.max_by(&:version)
      end

      latest_versions.keys.sort.each do |type_name|
        file_version = latest_versions[type_name]
        all_versions = type_versions[type_name].map(&:version).sort
        version_comment = all_versions.size > 1 ? " -- versions: #{all_versions.join(", ")}" : ""

        # Remove any leading/trailing whitespace from SQL definition
        sql_def = file_version.sql_definition.strip

        stream.puts <<-TYPE
  create_type "#{type_name}", sql_definition: <<-SQL#{version_comment}
    #{sql_def}
  SQL

        TYPE
      end

      stream.puts
    end
  end
end
