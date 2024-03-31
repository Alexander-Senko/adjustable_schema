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

		config.active_record
				.automatically_invert_plural_associations = true
	end
end
