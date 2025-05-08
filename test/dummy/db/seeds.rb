# This file should contain all the record creation needed to seed the database with its default values.

# Setup model relationships
AdjustableSchema.module_eval do
	relationship! Model1

	relationship! Model1 => Model2, roles: %i[
			role1
			role2
	]
end
