# frozen_string_literal: true

module AdjustableSchema
	module ActiveRecord
		module Builder # :nodoc:
			def relationship! *models, roles: [], **mapping
				return relationship!({ **Hash[*models], **mapping }, roles:) if
						mapping.any? # support keyword arguments syntax

				case models
				in [
						String | Symbol | Class => source,
						String | Symbol | Class => target,
				]
					define_relationship source, target,
							roles:
				in [ Hash => models ]
					define_relationships models,
							roles:
				in [ String | Symbol | Class => model ]
					define_recursive_relationship model,
							roles:
				end
			end

			def role! name
				Relationship::Role.find_or_create_by! name:
			end

			private

			def define_recursive_relationship model, roles: []
				define_relationship model, model, roles:
			end

			def define_relationships models, roles: []
				models
						.flat_map { it.map { Array it }.reduce &:product }
						.each { define_relationship *it, roles: }
			end

			def define_relationship source_type, target_type, roles: []
				roles
						.map { role! it }
						.then { it.presence or [ nil ] } # no roles => nameless relationship
						.map { |role| Relationship.create! source_type:, target_type:, role: }
			end
		end
	end
end
