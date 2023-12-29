require 'memery'

module AdjustableSchema
	module ActiveRecord
		concern :Relationships do
			class_methods do
				include Memery

				memoize def relationships
					Config.association_directions.to_h do
						[ _1, Relationship.abstract.send(Config.shortcuts.opposite[_1], self) ]
					end
				end

				def roles(&) = Role.of self, &
			end

			concern :InstanceMethods do # to include when needed
				def related?(...)
					relationships(...)
							.any?
				end

				def related(...)
					relationships(...)
							.preload(Config.association_directions)
							.map do |relationship|
								Config.association_directions
										.map { relationship.send _1 } # both objects
										.without(self) # the related one
										.first or self # may be self-related
							end
							.uniq
				end

				def relationships **options
					if (direction, scope = Config.find_direction **options) # filter by direction & related objects
						relationships_to(direction)
								.send Config.shortcuts[direction], scope
					else # all in both directions
						Config.association_directions
								.map { relationships_to _1 }
								.reduce(&:or)
					end
				end

				private

				def relationships_to direction
					try "#{direction}_relationships" or
							Relationship.none
				end
			end
		end
	end
end
