module AdjustableSchema
	module ActiveRecord
		concern :Associations do
			class_methods do
				private

				def adjust_associations
					relationships.each do |direction, relationships|
						relationships
								.select(&:"#{direction}_type")
								.each do |relationship|
									setup_association direction, relationship.send("#{direction}_type").constantize, relationship.role
								end
					end
				end

				def setup_association direction, target = self, role = nil
					adjustable_association(direction, target      ).define
					adjustable_association(direction, target, role).define if role

					include Relationships::InstanceMethods
				end

				def adjustable_association(...)
					Association.new(self, ...)
				end
			end
		end
	end
end
