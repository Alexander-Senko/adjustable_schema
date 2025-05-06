# frozen_string_literal: true

module AdjustableSchema
	module ActiveRecord
		module Association::Referenced # :nodoc:
			private

			def scopes
				role = self.role.name # save the context

				{
						**super,

						referenced_name => -> { referenced_by it, role: },
				}
			end

			def flags
				name = self.name # save the context

				{
						**super,

						referenced_name => -> { it.in? send name },
				}
			end

			def setters
				role = self.role.name # save the context

				{
						**super,

						referenced_name => -> { referenced_by! it, role: },
				}
			end

			using Association::Inflections

			def referenced_name = :"#{object_name.passivize}_by"
		end
	end
end
