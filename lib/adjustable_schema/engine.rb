# frozen_string_literal: true

require 'organizer'

module AdjustableSchema
	class Engine < ::Rails::Engine # :nodoc:
		isolate_namespace AdjustableSchema

		config.names = {
				associations: {
						source: {
								shortcut:  :of,
								self:      :child,
								reference: :referenced_by,
								recursive: :descendants,
						},
						target: {
								shortcut:  :to,
								self:      :parent,
								reference: :referencing,
								recursive: :ancestors,
						},
				},
		}

		config.actor_model_names = %w[
				User
		]
	end
end
