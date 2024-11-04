# frozen_string_literal: true

require_relative "lib/pg_types/version"

Gem::Specification.new do |spec|
  spec.name = "pg_types"
  spec.version = PgTypes::VERSION
  spec.authors = ["mhenrixon"]
  spec.email = ["mikael@mhenrixon.com"]

  spec.summary = "Rails integration for PostgreSQL custom types"
  spec.description = <<~DESC
    Manage PostgreSQL custom types (composite types, enums, domains) in your Rails application with
    versioned migrations and schema handling. This cuts the need for keeping a structure.sql
    while still maintaining proper type definitions in your Rails application.
  DESC

  spec.homepage = "https://github.com/mhenrixon/pg_types"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  # Important metadata for RubyGems
  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/mhenrixon/pg_types",
    "changelog_uri" => "https://github.com/mhenrixon/pg_types/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://github.com/mhenrixon/pg_types#readme",
    "bug_tracker_uri" => "https://github.com/mhenrixon/pg_types/issues",
    "rubygems_mfa_required" => "true",
    "github_repo" => "ssh://github.com/mhenrixon/pg_types",
    "funding_uri" => "https://github.com/sponsors/mhenrixon"
  }

  # Files to include
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) || f.start_with?(*%w[bin/ test/ spec/ features/ .git Rakefile .gitignore .rubocop.yml db/ .github
                                          appveyor Gemfile .rspec .ruby-version])
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "activerecord", ">= 6.1"
  spec.add_dependency "pg", ">= 1.1"
  spec.add_dependency "railties", ">= 6.1"
end
