# frozen_string_literal: true

# spec/generators/pg/type/type_generator_spec.rb
require "spec_helper"
require "ammeter/init"
require "generators/pg/type/type_generator"

RSpec.describe Pg::Generators::TypeGenerator, type: :generator do
  include TestHelpers

  destination File.expand_path("../../tmp", __dir__)

  before do
    prepare_destination
    FileUtils.mkdir_p(File.join(destination_root, "db", "types"))
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  describe "generator" do
    context "with default version" do
      before { run_generator ["contact_info"] }

      it "creates type file" do
        type_file = "db/types/contact_info_v1.sql"
        verify_file_exists(File.join(destination_root, type_file))
        expect(File.read(File.join(destination_root, type_file))).to include("CREATE TYPE contact_info")
      end

      it "creates migration file" do
        migration_path = File.join(destination_root, "db/migrate")
        migration_file = Dir["#{migration_path}/*create_type_contact_info.rb"].first
        verify_file_exists(migration_file)
        expect(File.read(migration_file)).to match(/create_type "contact_info", version: 1/)
      end
    end

    context "with specified version" do
      before { run_generator ["address_type", "--version", "2"] }

      it "creates versioned type file" do
        type_file = "db/types/address_type_v2.sql"
        verify_file_exists(File.join(destination_root, type_file))
        expect(File.read(File.join(destination_root, type_file))).to include("CREATE TYPE address_type")
      end

      it "creates migration with specified version" do
        migration_path = File.join(destination_root, "db/migrate")
        migration_file = Dir["#{migration_path}/*create_type_address_type.rb"].first
        verify_file_exists(migration_file)
        expect(File.read(migration_file)).to match(/create_type "address_type", version: 2/)
      end
    end

    context "with fields" do
      before { run_generator ["contact_info", "--fields", "email:text", "phone:varchar", "active:boolean"] }

      it "creates type file with specified fields" do
        type_file = "db/types/contact_info_v1.sql"
        content = File.read(File.join(destination_root, type_file))

        expect(content).to include("email text")
        expect(content).to include("phone varchar")
        expect(content).to include("active boolean")
      end
    end
  end
end
