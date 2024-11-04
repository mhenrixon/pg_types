# frozen_string_literal: true

module PgTypes
  module CommandRecorder
    def create_type(*args, &block)
      record(:create_type, args, &block)
    end

    def drop_type(*args)
      record(:drop_type, args)
    end

    def invert_create_type(args)
      [:drop_type, [args.first]]
    end

    def invert_drop_type(args)
      # When inverting a drop_type, we need the version from the original file
      type_name = args.first
      version = find_latest_version(type_name)

      [:create_type, [type_name, { version: version }]]
    end

    private

    def find_latest_version(type_name)
      files = Dir[Rails.root.join("db/types/#{type_name}_v*.sql")]
      return 1 if files.empty?

      files.map { |f| f.match(/_v(\d+)\.sql$/)[1].to_i }.max
    end
  end
end
