# frozen_string_literal: true

module AdjustableSchema # :nodoc:
	concern :Actors do
		class_methods do
			def actor?
				Config.actor_models.any? { self <= it }
			end
		end
	end
end
