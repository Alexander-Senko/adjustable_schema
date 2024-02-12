module AdjustableSchema
	module ActiveRecord
		class Association < Struct.new(:owner, :direction, :target, :role)
			require_relative 'association/naming'

			def define
				name.tap do |association_name|
					has_many association_name,
							through:     define_relationships,
							source:      direction,
							source_type: target.base_class.name,
							class_name:  target.name

					define_role_methods unless role
				end
			end

			def self_targeted? = target == owner

			private

			def define_relationships
				relationships_name.tap do |association_name|
					has_many association_name, (role = self.role) && -> { where role: },
							as:         Config.association_directions.opposite(to: direction),
							class_name: 'AdjustableSchema::Relationship'
				end
			end

			def define_role_methods
				name = self.name

				owner.redefine_method "#{name}_with_roles" do |*roles|
					send(name)
							.merge Relationship.named *roles
				end
			end

			def has_many(association_name, ...)
				return if owner.reflect_on_association association_name

				owner.has_many(association_name, ...)
			end
		end
	end
end
