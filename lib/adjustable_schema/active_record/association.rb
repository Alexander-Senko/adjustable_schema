require 'memery'

module AdjustableSchema
	module ActiveRecord
		class Association < Struct.new(:owner, :direction, :target, :role)
			require_relative 'association/naming'
			require_relative 'association/scopes'
			require_relative 'association/roleless'
			require_relative 'association/hierarchy'

			include Memery

			def initialize(...)
				super

				extend Roleless  if roleless?
				extend Hierarchy if hierarchy?
			end

			def define
				association = self # save the context

				has_many name, **options do
					include Scopes
					include Scopes::Recursive if association.recursive?
				end

				define_scopes
				define_methods
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
				scopes
						.reject { owner.singleton_class.method_defined? _1 }
						.each   { owner.scope _1, _2 }
			end

			def define_methods
				flags
						.transform_keys { "#{_1}?" }
						.reject { owner.method_defined? _1 }
						.each   { owner.define_method _1, &_2 }
			end

			def has_many(association_name, ...)
				return if owner.reflect_on_association association_name

				owner.has_many(association_name, ...)
			end

			def scopes
				name = relationships_name # save the context

				{
						name_for_any  => -> { where.associated name },
						name_for_none => -> { where.missing    name },
				}
			end

			def flags
				name = self.name # save the context

				{
						name_for_any  => -> { send(name).any?  },
						name_for_none => -> { send(name).none? },
				}
			end

			memoize def options = {
					through:     define_relationships,
					source:      direction,
					source_type: target.base_class.name,
					class_name:  target.name,
			}
		end
	end
end
