# frozen_string_literal: true

module PgTypes
  class Railtie < Rails::Railtie
    initializer "postgres_aggregates.load" do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::ConnectionAdapters::AbstractAdapter.include PgTypes::SchemaStatements
        ActiveRecord::Migration::CommandRecorder.include PgTypes::CommandRecorder
        ActiveRecord::SchemaDumper.prepend PgTypes::SchemaDumper
      end
    end
  end
end
