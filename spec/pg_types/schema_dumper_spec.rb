# frozen_string_literal: true

require "spec_helper"

RSpec.describe PgTypes::SchemaDumper do
  include TestHelpers

  let(:simple_type) do
    <<~SQL
      CREATE TYPE contact_info AS (
        email text,
        phone varchar,
        active boolean
      );
    SQL
  end

  let(:complex_type) do
    <<~SQL
      CREATE TYPE contact_info AS (
        email text,
        phone varchar,
        active boolean,
        preferences jsonb,
        last_contact timestamp with time zone
      );
    SQL
  end

  describe "schema dumping" do
    it "dumps a single type" do
      # Create the type directly in the database
      ActiveRecord::Base.connection.execute(simple_type)

      schema = dump_schema
      expect(schema).to include('create_type "contact_info"')
      expect(schema).to include("email text")
      expect(schema).to include("phone character varying")
      expect(schema).to include("active boolean")
    end

    it "dumps complex types with all attributes" do
      # Create a more complex type
      ActiveRecord::Base.connection.execute(complex_type)

      schema = dump_schema
      expect(schema).to include('create_type "contact_info"')
      expect(schema).to include("preferences jsonb")
      expect(schema).to include("last_contact timestamp with time zone")
    end

    it "sorts types by name" do
      # Create two types with different names
      zebra_sql = <<~SQL
        CREATE TYPE zebra_type AS (
          name text,
          value integer
        );
      SQL

      alpha_sql = <<~SQL
        CREATE TYPE alpha_type AS (
          name text,
          value integer
        );
      SQL

      ActiveRecord::Base.connection.execute(zebra_sql)
      ActiveRecord::Base.connection.execute(alpha_sql)

      schema = dump_schema
      alpha_pos = schema.index("alpha_type")
      zebra_pos = schema.index("zebra_type")
      expect(alpha_pos).to be < zebra_pos
    end
  end
end
