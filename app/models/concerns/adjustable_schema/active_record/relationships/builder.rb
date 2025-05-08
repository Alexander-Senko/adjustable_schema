# frozen_string_literal: true

module AdjustableSchema
	module ActiveRecord
		module Relationships
			module Builder # :nodoc:
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
		end
	end
end
