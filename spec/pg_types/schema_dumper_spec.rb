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
    it "dumps a single version type" do
      with_type_file("contact_info", 1, simple_type) do
        schema = dump_schema
        expect(schema).to include('create_type "contact_info"')
        expect(schema).to include(simple_type.strip)
        expect(schema).not_to include("versions:")
      end
    end

    it "dumps the latest version when multiple versions exist" do
      with_type_file("contact_info", 1, simple_type) do
        with_type_file("contact_info", 2, complex_type) do
          schema = dump_schema
          expect(schema).to include('create_type "contact_info"')
          expect(schema).to include(complex_type.strip)
          expect(schema).to include("versions: 1, 2")
        end
      end
    end

    it "sorts types by name" do
      with_type_file("zebra_type", 1, simple_type) do
        with_type_file("alpha_type", 1, simple_type) do
          schema = dump_schema
          alpha_pos = schema.index("alpha_type")
          zebra_pos = schema.index("zebra_type")
          expect(alpha_pos).to be < zebra_pos
        end
      end
    end
  end
end
