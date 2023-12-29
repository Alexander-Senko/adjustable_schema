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
			end
		end
	end
end
