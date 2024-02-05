require_relative "lib/adjustable_schema/version"
require_relative 'lib/adjustable_schema/authors'

Gem::Specification.new do |spec|
  spec.platform = Gem::Platform::RUBY
  spec.name        = "adjustable_schema"
  spec.version     = AdjustableSchema::VERSION
  spec.authors     = AdjustableSchema::AUTHORS.filter_map &:name
  spec.email       = AdjustableSchema::AUTHORS.filter_map &:email
  spec.homepage    = "#{AdjustableSchema::AUTHORS.filter_map(&:github_url).first}/#{spec.name}"
  spec.summary     = 'Adjustable data schemas for Rails'
  spec.description = 'Rails Engine to allow ActiveRecord associations be set up in the DB instead of being hard-coded.'
  spec.license     = "MIT"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.metadata['source_code_uri']}/blob/v#{spec.version}/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", 'CHANGELOG.md']
  end

  spec.required_ruby_version = '>= 3.2'

  spec.add_dependency 'rails', '~> 7.1'

  spec.add_dependency 'rails_model_load_hook', '~> 0.2'
  spec.add_dependency 'organizer-rails'

  spec.add_dependency 'memery'
end
