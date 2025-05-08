# Adjustable Schema for Rails

![GitHub Actions Workflow Status](
https://img.shields.io/github/actions/workflow/status/Alexander-Senko/adjustable_schema/ci.yml
)
![Code Climate maintainability](
https://img.shields.io/codeclimate/maintainability-percentage/Alexander-Senko/adjustable_schema
)
![Code Climate coverage](
https://img.shields.io/codeclimate/coverage/Alexander-Senko/adjustable_schema
)

Define your model associations in the database without changing the schema or models.

This Rails Engine was renamed and refactored from [Rails Dynamic Associations](https://github.com/Alexander-Senko/rails_dynamic_associations).

## Features

* Creates associations for your models when application starts.
* Provides `Relationship` & `Relationship::Role` models.
* No configuration code needed.
* No code generated or inserted to your app (except migrations).
* Adds some useful methods to `ActiveRecord` models to handle their relationships.

## Usage

Add configuration records to the DB:

``` ruby
AdjustableSchema::Relationship.create! source_type: 'Person',
                                       target_type: 'Book'
```

Or use a helper method:

``` ruby
AdjustableSchema.relationship! Person => Book
```

Now you have:

``` ruby
person.books
book.people
```

### Roles

You can create multiple role-based associations between two models.

``` ruby
AdjustableSchema.relationship! Person => Book, roles: %w[author editor]
```

You will get:

``` ruby
person.books
person.authored_books
person.edited_books

book.people
book.author_people
book.editor_people
```

#### Special cases

##### “Actor-like” models

In case you have set up relationships with `User` model you'll get a slightly different naming:

``` ruby
AdjustableSchema.relationship! User => Book, roles: %w[author editor]
```

``` ruby
book.users
book.authors
book.editors
```

The list of models to be handled this way can be set with `actor_model_names` configuration parameter.
It includes `User` by default.

``` ruby
AdjustableSchema::Engine.configure do
  config.actor_model_names << 'Person'
end
```

> [!CAUTION]
> Names are passed instead of model classes not to mess the loading up.

##### Self-referencing models

You may want to set up recursive relationships:

``` ruby
AdjustableSchema.relationship! Person, roles: %w[friend]
```

In this case you'll get these associations:

``` ruby
person.parents
person.children # for all the children
person.people   # for "roleless" children, not friends
person.friends
person.friended_people
```

If you prefer a different naming over `parents` & `children`, you can configure it like this:

```ruby
AdjustableSchema::Engine.configure do
  config.names[:associations][:source][:self] = :effect
  config.names[:associations][:target][:self] = :cause
end
```

Thus, for hierarchical `Event`s, you'll get:

``` ruby
event.causes
event.effects
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "adjustable_schema"
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install adjustable_schema
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
