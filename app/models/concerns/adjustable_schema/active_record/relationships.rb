# frozen_string_literal: true

require 'memery'

module AdjustableSchema
	module ActiveRecord # :nodoc:
		concern :Relationships do
			ANY = Object.new

			class_methods do
				include Memery

				memoize def relationships
					Config.association_directions.index_with do
						Relationship.abstract.send Config.shortcuts.opposite[it], self
					end
				end

				def roles(&) = Role.of self, &

				private

				def define_reference_scope direction, name
					scope name, -> records, role: ANY do
						joins(relationships = :"#{direction}_relationships")
								.distinct
								.where(
										relationships => { id: Relationship
												.send(Config.shortcuts[direction], records) # [to|of]: records
												.then do
													case role
													when ANY
														it
													when nil
														it.nameless
													else
														it.named *role
													end
												end,
										},
								)
					end
				end

				def define_reference_setter direction, name
					define_method "#{name}!" do |records, **options|
						reference! direction => records, **options
					end
				end

				def define_recursive_method association_name, method
					define_method method do
						send(association_name)
								.recursive
					end
				end
			end

			concern :InstanceMethods do # to include when needed
				included do
					scope :roleless, -> { merge Relationship.nameless }

					Config.association_directions.references
							.select { reflect_on_association "#{_1}_relationships" }
							.tap do
								it
										.reject { respond_to? _2 }
										.each   { define_reference_scope _1, _2 }
								it
										.reject { method_defined? "#{_2}!" }
										.each   { define_reference_setter _1, _2 }
							end

					Config.association_directions.recursive
							.select { reflect_on_association _1 }
							.reject { method_defined? _2 }
							.each   { define_recursive_method _1, _2 }
				end

				def related?(...)
					relationships(...)
							.any?
				end

				def related(...)
					relationships(...)
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
							.preload(Config.association_directions)
				end

				private

				def reference! source: self, target: self, role: nil
					role &&= Relationship::Role[role]

					[ source, target ]
							.map { Array it }
							.reduce(&:product)
							.each do |source, target|
								Relationship.create! source:, target:, role:
							rescue ::ActiveRecord::RecordNotUnique
								# That’s OK, it’s already there
							end

					self # for chainability
				end

				def relationships_to direction
					try "#{direction}_relationships" or
							Relationship.none
				end
			end
		end
	end
end
