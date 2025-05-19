# frozen_string_literal: true

module AdjustableSchema
	module ActiveRecord # :nodoc:
		concern :Associations do
			class_methods do
				protected

				def adjust_associations
					adjust_parent_associations

					relationships
							.flat_map do |direction, relationships|
								relationships
										.select(&:"#{direction}_type")
										.each do |relationship|
											setup_association direction, relationship.send("#{direction}_type").constantize, relationship.role
										end
							end
							.presence
							&.tap do # finally, if any relationships have been set up
								include Relationships::InstanceMethods
							end
				end

				private

				def adjust_parent_associations
					return unless superclass < Associations

					superclass.adjust_associations

					_reflections.reverse_merge! superclass._reflections # update
				end

				def setup_association direction, target = self, role = nil
					adjustable_association(direction, target      ).define
					adjustable_association(direction, target, role).define if role
				end

				def adjustable_association(...)
					Association.new(self, ...)
				end
			end
		end
	end
end
