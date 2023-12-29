module AdjustableSchema
	module ActiveRecord
		module QueryMethods
			class WithChain
				def initialize scope
					@scope = scope
				end

				# Returns a new relation expressing WITH RECURSIVE statement.
				#
				# #recursive accepts conditions as a hash. See QueryMethods#with for
				# more details on each format.
				#
				#    User.with.recursive(
				#      descendants: User.joins('INNER JOIN descendants ON users.parent_id = descendants.id')
				#    )
				#    # WITH RECURSIVE descendants AS (
				#    #   SELECT * FROM users
				#    #   UNION
				#    #   SELECT * FROM users INNER JOIN descendants ON users.parent_id = descendants.id
				#    # ) SELECT * FROM descendants
				#
				# WARNING! Due to how Arel works,
				#  * `recursive` can't be chained with any prior non-recursive calls to `with` and
				#  * all subsequent non-recursive calls to `with` will be treated as recursive ones.
				def recursive *args
					args.map! do
						next _1 unless _1.is_a? Hash

						_1
								.map(&method(:with_recursive_union))
								.to_h
					end

					case @scope.with_values
					in []
						@scope = @scope.with :recursive, *args
					in [ :recursive, * ]
						@scope = @scope.with *args
					else
						raise ArgumentError, "can't chain `WITH RECURSIVE` with non-recursive one"
					end

					@scope
				end

				private

				def with_recursive_union name, scope
					scope = scope.arel if scope.respond_to? :arel

					[
							name,
							@scope
									.unscope(:order, :group, :having)
									.arel
									.union(scope)
					]
				end
			end

			def with *args
				if args.empty?
					WithChain.new spawn
				else
					super
				end
			end

			private

			# OVERWRITE: allow a Symbol to be passes as the first argument
			def build_with(arel)
				return if with_values.empty?

				with_statements = with_values.map.with_index do |with_value, i|
					next with_value if with_value.is_a? Symbol and i == 0

					raise ArgumentError, "Unsupported argument type: #{with_value} #{with_value.class}" unless with_value.is_a?(Hash)

					build_with_value_from_hash(with_value)
				end

				arel.with(*with_statements)
			end

			# OVERWRITE: allow Arel Nodes
			def build_with_value_from_hash(hash)
				hash.map do |name, value|
					expression =
							case value
							when Arel::Nodes::SqlLiteral then Arel::Nodes::Grouping.new(value)
							when ::ActiveRecord::Relation then value.arel
							when Arel::SelectManager, Arel::Nodes::Node then value
							else
								raise ArgumentError, "Unsupported argument type: `#{value}` #{value.class}"
							end
					Arel::Nodes::TableAlias.new(expression, name)
				end
			end
		end
	end
end
