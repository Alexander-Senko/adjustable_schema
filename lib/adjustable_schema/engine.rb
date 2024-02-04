require 'organizer'

module AdjustableSchema
	class Engine < ::Rails::Engine
		isolate_namespace AdjustableSchema

		config.names = {
				associations: {
						source: {
								shortcut:     :of,
								self_related: :child,
								recursive:    :descendants,
						},
						target: {
								shortcut:     :to,
								self_related: :parent,
								recursive:    :ancestors,
						},
				},
		}
	end
end
