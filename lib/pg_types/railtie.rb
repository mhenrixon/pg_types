# frozen_string_literal: true

module PgTypes
  class Railtie < Rails::Railtie
    initializer "pg_types.load", after: "pg_aggregates.load" do
      ActiveSupport.on_load(:active_record) do
        PgTypes.load
      end
    end
  end
end
