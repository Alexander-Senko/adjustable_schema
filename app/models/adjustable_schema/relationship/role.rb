module AdjustableSchema
	class Relationship
		class Role < ApplicationRecord
			include Organizer::Identifiable.by :name

			has_many :relationships

			validates :name, presence: true, uniqueness: true

			# FIXME: depends on default naming
			scope :available, ->        { with_relationships { of :abstract } }
			scope :of,        -> source { with_relationships { of source    } }
			scope :for,       -> target { with_relationships { to target    } }

			def self.with_relationships(&)
				joins(:relationships)
						.merge Relationship.instance_eval(&)
			end

			class << self
				def [] *names, **scopes
					return super *names if names.any?

					scopes
							.map { of(_1).for _2 }
							.reduce &:merge
				end
			end
		end
	end
end
