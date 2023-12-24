module AdjustableSchema
	class Relationship
		class Role < ApplicationRecord
			include Organizer::Identifiable.by :name, symbolized: true

			has_many :relationships

			validates :name, presence: true, uniqueness: true

			scope :available, ->        { with_relationships { send Config.shortcuts[:source], :abstract } }
			scope :of,        -> source { with_relationships { send Config.shortcuts[:source], source    } }
			scope :for,       -> target { with_relationships { send Config.shortcuts[:target], target    } }

			def self.with_relationships(&)
				joins(:relationships)
						.merge Relationship.instance_eval(&)
			end

			class << self
				def [] *names, **scopes
					if scopes.any?
						with_relationships { self[**scopes] }
								.distinct
					else
						all
					end
							.scoping { names.any? ? super(*names) : all }
				end
			end
		end
	end
end
