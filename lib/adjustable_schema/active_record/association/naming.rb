require 'memery'

module AdjustableSchema
	module ActiveRecord
		class Association
			concerning :Naming do
				include Memery

				module Inflections
					refine String do
						def passivize
							sub(/(e?d?|ing|[eo]r|ant|(t)ion)$/, '\\2ed')
						end
					end
				end

				using Inflections

				memoize def name
					(role ? name_with_role : name_without_role)
							.to_s
							.tableize
							.to_sym
				end

				memoize def target_name
					target.name
							.split('::')
							.reverse
							.join
							.underscore
				end

				def relationships_name = :"#{role ? name_with_role : direction}_relationships"

				private

				memoize def name_with_role
					if self_targeted?
						{
								source: role.name,
								target: "#{role.name.passivize}_#{target_name}",
						}[direction]
					else
						"#{{
								source: role.name,
								target: role.name.passivize,
						}[direction]}_#{target_name}"
					end
				end

				memoize def name_without_role
					if self_targeted?
						Config.association_directions
								.self_related[direction]
					else
						target_name
					end
				end
			end
		end
	end
end
