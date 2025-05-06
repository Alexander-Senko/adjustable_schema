# frozen_string_literal: true

require 'memery'

module AdjustableSchema
	module ActiveRecord
		class Association # :nodoc:
			concerning :Naming do
				include Memery

				module Inflections # :nodoc:
					refine String do
						def passivize
							presence
									&.sub(/((:?[aeiou]+[^aeiou]+){2,})(?:or|ant|ion|e?ment)$/, '\1ed')
									&.sub(/((:?[aeiou]+[^aeiou]+){1,})(?:ing)$/,               '\1ed')
									&.sub(/(?:e*|ed|er)$/,                                     '\1ed')
									.to_s
						end
					end
				end

				using Inflections

				module Recursive # :nodoc:
					include Memery

					memoize def name_with_role = {
							source: role.name,
							target: "#{role.name.passivize}_#{target_name}",
					}[direction]

					def name_without_role
						Config.association_directions
								.self[direction]
								.to_s
					end
				end

				module Actors # :nodoc:
					include Memery

					memoize def name_with_role = {
							source: role.name,
							target: "#{role.name.passivize}_#{target_name}",
					}[direction]

					def name_for_any(name = object_name) = name
							.passivize
							.to_sym
				end

				def initialize(...)
					super

					extend Recursive if recursive?
					extend Actors    if target.actor?
				end

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

				memoize def name_with_role = "#{{
						source: role.name,
						target: role.name.passivize,
				}[direction]}_#{target_name}"

				def name_without_role = target_name

				def name_for_any (name = object_name) = :"#{name}ful"
				def name_for_none(name = object_name) = :"#{name}less"
			end
		end
	end
end
