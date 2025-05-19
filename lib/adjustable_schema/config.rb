# frozen_string_literal: true

require 'memery'

module AdjustableSchema
	module Config # :nodoc:
		include Memery

		module Naming # :nodoc:
			include Memery

			memoize def shortcuts
				config(:shortcut).tap do |shortcuts|
					def shortcuts.opposite to: nil
						if to
							values.grep_v(to).sole
						else
							transform_values { opposite to: it }
						end
					end
				end
			end

			def self       = config :self
			def references = config :reference

			def recursive
				config.values.to_h do
					[ it[:self].to_s.pluralize.to_sym, it[:recursive].to_sym ]
				end
			end

			def opposite to:
				grep_v(to).sole
			end

			def with_opposite
				index_with { opposite to: it }
			end

			private

			def config section = nil
				if section
					config.transform_values { it[section].to_sym }
				else
					Config.association_names # TODO: DRY
				end
			end
		end

		module_function

		memoize def association_directions
			association_names.keys.tap do |directions|
				class << directions
					include Naming
				end
			end
		end

		def find_direction(...)
			normalize(...)
					.find { |dir, *| dir.in? association_directions }
		end

		for method in %i[
				shortcuts
		] do
			delegate        method, to: :association_directions
			module_function method
		end

		memoize def actor_models
			Engine.config.actor_model_names
					.filter_map &:safe_constantize
		end

		def association_names = Engine.config.names[:associations]

		def normalize **options
			shortcuts
					.tap { options.assert_valid_keys it.keys, it.values }
					.select { _2.in? options }
					.each { options[_1] = options.delete _2 }

			options
		end
	end
end
