require 'memery'

module AdjustableSchema
	module ActiveRecord
		class Association
			concerning :Naming do
				include Memery

				module Inflections
					refine String do
						def passivize
							self
									.sub(/(author)$/, '\\2ed')
									.sub(/(e*|ed|ing|[eo]r|ant|(t)ion)$/, '\\2ed')
						end
					end
				end

				using Inflections

				memoize def name name = object_name
					name
							.to_s
							.tableize
							.to_sym
				end

				def object_name
					if role
						name_with_role
					else
						name_without_role
					end
				end

				memoize def target_name
					target.model_name.unnamespaced
							.split('::')
							.reverse
							.join
							.underscore
				end

				def relationships_name = :"#{role ? name_with_role : direction}_relationships"

				private

				memoize def name_with_role
					if recursive?
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

				def name_without_role
					if recursive?
						Config.association_directions
								.self[direction]
								.to_s
					else
						target_name
					end
				end

				def roleless_name = name(target_name)

				def name_for_any (name = object_name) = :"#{name.passivize}"
				def name_for_none(name = object_name) = :"#{name}less"
			end
		end
	end
end
