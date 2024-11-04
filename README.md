# PgTypes

PgTypes provides Rails integration for managing PostgreSQL custom types (composite types, enums, domains). It allows you to version your custom types and handle them through migrations, similar to how you manage database schema changes, while maintaining a clean `schema.rb` file.

## Features

- Versioned PostgreSQL types
- Rails generator for creating new types
- Migration support for adding/removing types
- Proper schema.rb dumping (no need for structure.sql)
- Support for multiple PostgreSQL versions
- Support for composite types, enums, and domains
- Dependencies tracking and proper ordering

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pg_types'
```

And then execute:

```bash
$ bundle install
```

## Usage

### Creating a New Type

Generate a new type:

```bash
# Create a simple type
$ rails generate pg:type contact_info

# Create a type with fields
$ rails generate pg:type contact_info --fields email:text phone:varchar active:boolean

# Create a specific version
$ rails generate pg:type contact_info --version 2
```

This will create:
- A SQL file in `db/types/contact_info_v1.sql`
- A migration file to create the type

### SQL Definition

Edit the generated SQL file (`db/types/contact_info_v1.sql`):

```sql
CREATE TYPE contact_info AS (
  email text,
  phone varchar,
  active boolean
);
```

For an enum type:

```sql
CREATE TYPE status AS ENUM (
  'active',
  'pending',
  'inactive'
);
```

For a domain type:

```sql
CREATE DOMAIN positive_integer AS integer
  CHECK (VALUE > 0);
```

### Migrations

The generated migration will look like:

```ruby
class CreateTypeContactInfo < ActiveRecord::Migration[7.0]
  def change
    create_type "contact_info", version: 1
  end
end
```

You can also create types inline:

```ruby
class CreateTypeUserStatus < ActiveRecord::Migration[7.0]
  def change
    create_type "user_status", sql_definition: <<-SQL
      CREATE TYPE user_status AS ENUM (
        'active',
        'pending',
        'inactive'
      );
    SQL
  end
end
```

### Managing Versions

When you need to update a type, create a new version:

1. Generate a new version:
```bash
$ rails generate pg:type contact_info --version 2 --fields email:text phone:varchar active:boolean preferences:jsonb
```

2. Update the SQL in `db/types/contact_info_v2.sql`

3. Create a migration to update to the new version:
```ruby
class UpdateTypeContactInfo < ActiveRecord::Migration[7.0]
  def change
    drop_type "contact_info", force: true  # Use force: true if the type is used in tables
    create_type "contact_info", version: 2
  end
end
```

### Using Types in Your Models

After creating your types, you can use them in your models:

```ruby
# For composite types
class User < ApplicationRecord
  attribute :contact_info, :contact_info  # Requires additional setup with ActiveRecord
end

# For enum types
class User < ApplicationRecord
  enum status: {
    active: 'active',
    pending: 'pending',
    inactive: 'inactive'
  }, _prefix: true
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To run tests against multiple Rails versions:

```bash
bundle exec appraisal install
bundle exec appraisal rake spec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mhenrixon/pg_types. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/mhenrixon/pg_types/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PgTypes project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mhenrixon/pg_types/blob/main/CODE_OF_CONDUCT.md).