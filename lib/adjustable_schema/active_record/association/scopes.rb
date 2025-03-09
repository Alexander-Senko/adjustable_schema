module AdjustableSchema
	module ActiveRecord
		module Association::Scopes
			module Recursive
				def recursive
					with_recursive(recursive_table.name => [ recursion_base, recursive_step ])
							.unscope(:select, :joins, :where)
							.from(recursive_table.alias table_name)
							.distinct
									.unscope(:order) # for SELECT DISTINCT, ORDER BY expressions must appear in select list
				end

				private

				def recursion_base
					unscope(:order, :group, :having)
							.select(recursive_select_values,
									Arel.sql('1').as('distance'),
							)
				end

				def recursive_step
					unscoped
							.select(recursive_select_values,
									(recursive_table[:distance] + 1).as('distance'),
							)
							.joins(inverse_association_name)
							.joins(<<~SQL.squish)
								JOIN #{recursive_table.name}
									ON #{recursive_table.name}.#{primary_key} = #{inverse_table.name}.#{primary_key}
							SQL
				end

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

				def recursive_select_values = select_values.presence || arel_table[Arel.star]
			end
		end
	end
end
