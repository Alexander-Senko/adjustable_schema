require 'organizer'

module AdjustableSchema
	class Engine < ::Rails::Engine
		isolate_namespace AdjustableSchema

		config.names = {
				associations: {
						source: {
								shortcut:  :of,
								self:      :child,
								recursive: :descendants,
						},
						target: {
								shortcut:  :to,
								self:      :parent,
								recursive: :ancestors,
						},
				},
		}
	end
end
