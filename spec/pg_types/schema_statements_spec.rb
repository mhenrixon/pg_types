# frozen_string_literal: true

# spec/pg_types/schema_statements_spec.rb
require "spec_helper"

RSpec.describe PgTypes::SchemaStatements do
  include TestHelpers

  let(:connection) { ActiveRecord::Base.connection }

  describe "#create_type" do
    let(:type_sql) do
      <<~SQL
        CREATE TYPE contact_info AS (
          email text,
          phone varchar
        );
      SQL
    end

    it "creates a type from sql_definition" do
      connection.create_type("contact_info", sql_definition: type_sql)

      result = connection.select_value(<<-SQL)
        SELECT EXISTS (
          SELECT 1#{" "}
          FROM pg_type t#{" "}
          JOIN pg_namespace n ON t.typnamespace = n.oid#{" "}
          WHERE t.typname = 'contact_info'
          AND t.typtype = 'c'
          AND n.nspname = 'public'
        )
      SQL

      expect(result).to be true
    end

    it "creates a type from a versioned file" do
      with_type_file("contact_info", 1, type_sql) do
        connection.create_type("contact_info", version: 1)

        result = connection.select_value(<<-SQL)
          SELECT EXISTS (
            SELECT 1#{" "}
            FROM pg_type t#{" "}
            JOIN pg_namespace n ON t.typnamespace = n.oid#{" "}
            WHERE t.typname = 'contact_info'
            AND t.typtype = 'c'
            AND n.nspname = 'public'
          )
        SQL

        expect(result).to be true
      end
    end

    it "raises an error when neither sql_definition nor version is provided" do
      expect do
        connection.create_type("bad_type")
      end.to raise_error(ArgumentError)
    end
  end

  describe "#drop_type" do
    before do
      connection.execute(<<~SQL)
        CREATE TYPE contact_info AS (
          email text,
          phone varchar
        );
      SQL
    end

    it "drops an existing type" do
      connection.drop_type("contact_info")

      result = connection.select_value(<<-SQL)
        SELECT EXISTS (
          SELECT 1#{" "}
          FROM pg_type t#{" "}
          JOIN pg_namespace n ON t.typnamespace = n.oid#{" "}
          WHERE t.typname = 'contact_info'
          AND t.typtype = 'c'
          AND n.nspname = 'public'
        )
      SQL

      expect(result).to be false
    end

    it "doesn't raise error when dropping non-existent type" do
      expect do
        connection.drop_type("nonexistent_type")
      end.not_to raise_error
    end

    it "drops type with CASCADE when force: true" do
      # Create a dependent table using the type
      connection.execute(<<~SQL)
        CREATE TABLE test_contacts (
          id serial primary key,
          info contact_info
        );
      SQL

      expect do
        connection.drop_type("contact_info", force: true)
      end.not_to raise_error

      # Check if table exists using a more compatible approach
      table_exists = connection.select_value(<<~SQL)
        SELECT EXISTS (
          SELECT 1 FROM pg_catalog.pg_class c
          JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
          WHERE c.relname = 'test_contacts'
          AND n.nspname = 'public'
          AND c.relkind = 'r'
        )
      SQL
      expect(table_exists).to be false
    end
  end
end
