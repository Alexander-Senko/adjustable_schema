module AdjustableSchema
	module ActiveRecord
		module Association::Scopes
			concern :Recursive do
				require_relative '../query_methods'

				included do
					::ActiveRecord::QueryMethods.prepend QueryMethods # HACK: to bring `with.recursive` in
				end

				def recursive
					all._exec_scope do
						all
								.select(
										select_values = self.select_values.presence || arel_table[Arel.star],
										Arel.sql('1').as('distance'),
								)
								.with.recursive(recursive_table.name => unscoped
										.select(
												select_values,
												(recursive_table[:distance] + 1).as('distance'),
										)
										.joins(inverse_association_name)
										.arel
										.join(recursive_table)
												.on(recursive_table[primary_key].eq inverse_table[primary_key])
								)
								.unscope(:select, :joins, :where)
								.from(recursive_table.alias table_name)
								.distinct
										.unscope(:order) # for SELECT DISTINCT, ORDER BY expressions must appear in select list
					end
				end

				private

				def association_name = @association.reflection.name

				def inverse_association_name
					Config.association_directions
							.recursive
							.keys
							.without(association_name)
							.sole
				end

				def recursive_table = Arel::Table.new [ :recursive, association_name, klass.table_name ] * '_'
				def   inverse_table = Arel::Table.new [     inverse_association_name, klass.table_name ] * '_' # HACK: depends on ActiveRecord internals
			end
		end
	end
end
