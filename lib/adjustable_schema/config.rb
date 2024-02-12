require 'memery'

module AdjustableSchema
	module Config
		include Memery

		module Naming
			include Memery

			memoize def shortcuts
				config(:shortcut).tap do |shortcuts|
					def shortcuts.opposite to: nil
						if to
							values.reject { _1 == to }.sole
						else
							transform_values { opposite to: _1 }
						end
					end
				end
			end

			def self_related = config :self_related

			def recursive
				config.values.to_h do
					[ _1[:self_related].to_s.pluralize.to_sym, _1[:recursive].to_sym ]
				end
			end

			def opposite to:
				reject { _1 == to }.sole
			end

			private

			def config section = nil
				if section
					config.transform_values { _1[section].to_sym }
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

		private
		module_function

		def association_names = Engine.config.names[:associations]

		def normalize **options
			shortcuts
					.tap { options.assert_valid_keys _1.keys, _1.values }
					.select { _2.in? options }
					.each { options[_1] = options.delete _2 }

			options
		end
	end
end
