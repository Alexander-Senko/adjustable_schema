# frozen_string_literal: true

module AdjustableSchema
	# = Relationships
	#
	# `Relationship` is a core class of Adjustable Schema representing both
	# associations of model classes and connections of individual records.
	#
	# No constraints are supported yet, so only many-to-many associations
	# are available for now.
	#
	# == Model associations
	#
	# To represent an association, a `Relationship` record should have both
	# `source_type` and `target_type` columns set, with both ID columns set
	# to `NULL`.
	#
	# == Record relationships
	#
	# To connect individual records, both `source` and `target` polymorphic
	# associations shoud be set.
	#
	# == Roles
	#
	# Many associations with different semantics between the same models
	# can be set using roles (see `Relationship::Role`).
	class Relationship < ApplicationRecord
		belongs_to :source, polymorphic: true, optional: true
		belongs_to :target, polymorphic: true, optional: true
		belongs_to :role,                      optional: true

		default_scope do
			includes :role
		end

		Config.shortcuts.each &-> ((association, method)) do # rubocop:disable Style
			scope method, -> object {
				case object
				when ::ActiveRecord::Base, nil
					where association => object
				when Class
					where "#{association}_type" => object.ancestors
							.grep(..object.base_class)
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
					send(__method__).send method, object
				else
					where "#{association}_id" => nil
				end
			}
		end

		scope :abstract, -> {
			Config.shortcuts.values
					.map { send it, :abstract }
					.reduce &:merge
		}

		scope :general,  -> { where     target: nil }
		scope :sourced,  -> { where.not source: nil }
		scope :targeted, -> { where.not target: nil }
		scope :applied,  -> { sourced.targeted }

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
							self # rubocop:disable Style
									.send(Config.shortcuts[:source], _1)
									.send(Config.shortcuts[:target], _2)
						end
						.reduce &:or
			end

			def seed! *models, roles: [], **mapping # rubocop:disable Metrics
				return seed!({ **Hash[*models], **mapping }, roles:) if mapping.any? # support keyword arguments syntax

				case models
				in [
						String | Symbol | Class => source_type,
						String | Symbol | Class => target_type,
				]
					roles
							.map { |name| Role.find_or_create_by! name: }
							.then { it.presence or [ nil ] } # no roles => nameless relationship
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
	end
end
