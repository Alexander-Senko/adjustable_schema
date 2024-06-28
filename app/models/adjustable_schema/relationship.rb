module AdjustableSchema
	class Relationship < ApplicationRecord
		belongs_to :source, polymorphic: true, optional: true
		belongs_to :target, polymorphic: true, optional: true
		belongs_to :role,                      optional: true

		default_scope do
			includes :role
		end

		Config.shortcuts.each &-> ((association, method)) do
			scope method, -> object {
				case object
				when ::ActiveRecord::Base, nil
					where association => object
				when Class
					where "#{association}_type" => object.ancestors
							.select { _1 <= object.base_class }
							.map(&:name)
				when ::ActiveRecord::Relation
					send(method, object.klass)
							.where "#{association}_id" => object
				when Symbol
					send "#{method}_#{object}"
				else
					raise ArgumentError, "no relationships for #{object.inspect}"
				end
			}

			scope "#{method}_abstract", -> object = nil {
				if object
					send(__method__).
							send method, object
				else
					where "#{association}_id" => nil
				end
			}
		end

		scope :abstract, -> {
			Config.shortcuts.values
					.map { send _1, :abstract }
					.reduce &:merge
		}

		scope :general, -> {
			where target: nil
		}

		scope :applied, -> {
			where.not(
					source: nil,
					target: nil,
			)
		}

		scope :named, -> *names {
			case names
			when [] # i.e. `named`
				where.not role: nil
			else
				with_roles { where name: names }
			end
		}

		scope :nameless, -> { where role: nil }

		def self.with_roles(&)
			joins(:role)
					.merge Role.instance_eval(&)
		end

		class << self
			def [] **scopes
				scopes
						.map do
							self
									.send(Config.shortcuts[:source], _1)
									.send(Config.shortcuts[:target], _2)
						end
						.reduce &:or
			end

			def seed! *models, roles: [], **_models
				return seed!({ **Hash[*models], **_models }, roles:) if _models.any? # support keyword arguments syntax

				case models
				in [
						String | Symbol | Class => source_type,
						String | Symbol | Class => target_type,
				]
					roles
							.map { |name| Role.find_or_create_by! name: }
							.then { _1.presence or [ nil ] } # no roles => nameless relationship
							.map { |role| create! source_type:, target_type:, role: }
				in [ Hash => models ]
					for sources, targets in models do
						for source, target in Array(sources).product Array(targets) do
							seed! source, target, roles:
						end
					end
				in [ Class => source ]
					seed! source, source, roles: # recursive
				end
			end
		end

		delegate :name, to: :role, allow_nil: true

		def name= role_name
			self.role =
					role_name && Role[role_name]
		end

		def abstract? = not (source or target)

		# HACK
		# Using polymorphic associations in combination with single table inheritance (STI) is
		# a little tricky. In order for the associations to work as expected, ensure that you
		# store the base model for the STI models in the type column of the polymorphic
		# association.
		# https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#module-ActiveRecord::Associations::ClassMethods-label-Polymorphic+Associations
		reflections
				.values
				.select { _1.options[:polymorphic] }
				.each do |reflection|
					define_method "#{reflection.name}_type=" do |type|
						super type && type.to_s.classify.constantize.base_class.to_s
					end
				end
	end
end
