module AdjustableSchema
	module ActiveRecord
		class Association < Struct.new(:owner, :direction, :target, :role)
			require_relative 'association/naming'
			require_relative 'association/scopes'

			def define
				name.tap do |association_name|
					association = self # save context

					has_many association_name, **(options = {
							through:     define_relationships,
							source:      direction,
							source_type: target.base_class.name,
							class_name:  target.name
					}) do
						include Scopes
						include Scopes::Recursive if association.recursive?
					end

					define_scopes
					define_methods

					unless role
						# HACK: using `try` to overcome a Rails bug
						# (see https://github.com/rails/rails/issues/40109)
						has_many roleless_name, -> { try :roleless }, **options if
								child?

						define_role_methods
					end
				end
			end

			def recursive? = target == owner
			def roleless?  = !role
			def source?    = direction == :source
			def target?    = direction == :target
			def child?     = (recursive? and source?)
			def parent?    = (recursive? and target?)
			def hierarchy? = (child? and roleless?)

			private

			def define_relationships
				relationships_name.tap do |association_name|
					has_many association_name, (role = self.role) && -> { where role: },
							as:         Config.association_directions.opposite(to: direction),
							dependent:  :destroy_async,
							class_name: 'AdjustableSchema::Relationship'
				end
			end

			def define_scopes
				name          = relationships_name
				roleless_name = self.roleless_name

				{
						name_for_any  => -> { where.associated name },
						name_for_none => -> { where.missing    name },

						**({
								name_for_any( target_name) => -> { where.associated roleless_name },
								name_for_none(target_name) => -> { where.missing    roleless_name },
						} if hierarchy?),
				}
						.reject { owner.singleton_class.method_defined? _1 }
						.each   { owner.scope _1, _2 }
			end

			def define_methods
				name          = self.name
				roleless_name = self.roleless_name

				{
						name_for_any  => -> { send(name).any?  },
						name_for_none => -> { send(name).none? },

						**(hierarchy? ? {
								name_for_any( target_name) => -> { send(roleless_name).any?  },
								name_for_none(target_name) => -> { send(roleless_name).none? },
								intermediate:                 -> { send(roleless_name).one?  },
								branching:                    -> { send(roleless_name).many? },
						} : {}),
				}
						.transform_keys {"#{_1}?" }
						.reject { owner.method_defined? _1 }
						.each   { owner.define_method _1, &_2 }
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
