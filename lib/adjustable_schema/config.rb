module AdjustableSchema
	module Config
		module Naming
			def shortcuts
				@shortcuts ||= # cache
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
					[ _1[:self_related].to_s.pluralize.to_sym, _1[:recursive] ]
				end
			end

			def opposite to:
				reject { _1 == to }.sole
			end

			private

			def config section = nil
				if section
					config.transform_values { _1[section] }
				else
					Config.association_names # TODO: DRY
				end
			end
		end

		module_function

		def association_directions
			@association_directions ||= # cache
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
					.select { _2.in? options }
					.each { options[_1] = options.delete _2 }

			options
		end
	end
end
