module AdjustableSchema
	module ActiveRecord
		concern :Relationships do
			class_methods do
				def relationships
					@relationships ||= # cache
							Config.association_directions.to_h do
								[ _1, Relationship.abstract.send(Config.shortcuts.opposite[_1], self) ]
							end
				end

				def roles(&) = Role.of self, &

				private

				def define_recursive_methods association_name, method
					redefine_method tree_method = "#{method.to_s.singularize}_tree" do
						send(association_name)
								.inject([]) do |tree, node|
							tree << node << node.send(tree_method)
						end
								.reject &:blank?
					end

					redefine_method "#{method}_with_distance" do
						(with_distance = -> (level, distance) {
							case level
							when Array
								level.inject({}) do |hash, node|
									hash.merge with_distance[node, distance.next]
								end
							else
								{ level => distance }
							end
						})[send(tree_method), 0]
					end

					redefine_method method do
						send(tree_method).flatten
					end
				end
			end

			concern :InstanceMethods do # to include when needed
				included do
					Config.association_directions.recursive
							.select { reflect_on_association _1 }
							.reject { method_defined? _2 }
							.each { define_recursive_methods _1, _2 }
				end

				def related?(...)
					relationships(...)
							.values
							.reduce(&:or)
							.any?
				end

				def related(...)
					relationships(...)
							.flat_map do |direction, relationships|
								relationships
										.preload(direction)
										.map &direction
							end
							.uniq
				end

				def relationships *names, **options
					if (direction, scope = Config.find_direction options)
						{
								direction => relationships_to(direction)
										.try(Config.shortcuts[direction], scope) # filter by related objects
						}
					else # both directions
						Config.association_directions.to_h { [ _1, relationships_to(_1) ] }
					end
							.compact
							.tap do |relationships|
								break relationships.transform_values { _1.named names } if names.any? # filter by role
							end
				end

				private

				def relationships_to(direction) = try "#{direction}_relationships"
			end
		end
	end
end
