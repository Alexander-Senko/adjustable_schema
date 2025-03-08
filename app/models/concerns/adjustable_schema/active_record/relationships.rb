# frozen_string_literal: true

require 'memery'

module AdjustableSchema
	module ActiveRecord # :nodoc:
		concern :Relationships do
			class_methods do
				include Memery

				memoize def relationships
					Config.association_directions.index_with do
						Relationship.abstract.send Config.shortcuts.opposite[it], self
					end
				end

				def roles(&) = Role.of self, &

				private

				def define_recursive_methods association_name, method
					define_method method do
						send(association_name)
								.recursive
					end
				end
			end

			concern :InstanceMethods do # to include when needed
				included do
					scope :roleless, -> { merge Relationship.nameless }

					Config.association_directions.recursive
							.select { reflect_on_association _1 }
							.reject { method_defined? _2 }
							.each   { define_recursive_methods _1, _2 }
				end

				def related?(...)
					relationships(...)
							.any?
				end

				def related(...)
					relationships(...)
							.preload(Config.association_directions)
							.map do |relationship|
								Config.association_directions
										.map { relationship.send it } # both objects
										.without(self) # the related one
										.first or self # may be recursive
							end
							.uniq
				end

				def relationships(...)
					if (direction, scope = Config.find_direction(...)) # filter by direction & related objects
						relationships_to(direction)
								.send Config.shortcuts[direction], scope
					else # all in both directions
						Config.association_directions
								.map { relationships_to it }
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
