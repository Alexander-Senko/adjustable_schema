require "adjustable_schema/version"
require "adjustable_schema/engine"

module AdjustableSchema
	autoload :Config, 'adjustable_schema/config'

	module_function

	def available?
		Relationship.table_exists?
	end
end
