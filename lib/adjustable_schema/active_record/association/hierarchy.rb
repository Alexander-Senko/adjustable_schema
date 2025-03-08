# frozen_string_literal: true

module AdjustableSchema
	module ActiveRecord
		module Association::Hierarchy # :nodoc:
			private

			def scopes
				name = roleless_name # save the context

				{
						**super,

						name_for_any( target_name) => -> { where.associated name },
						name_for_none(target_name) => -> { where.missing    name },
				}
			end

			def flags
				name = roleless_name # save the context

				{
						**super,

						name_for_any( target_name) => -> { send(name).any?  },
						name_for_none(target_name) => -> { send(name).none? },
						intermediate:                 -> { send(name).one?  },
						branching:                    -> { send(name).many? },
				}
			end
		end
	end
end
