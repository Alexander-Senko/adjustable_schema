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
