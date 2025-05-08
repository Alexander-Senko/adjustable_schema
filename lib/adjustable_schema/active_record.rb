# frozen_string_literal: true

module AdjustableSchema
	module ActiveRecord # :nodoc:
		autoload :Association, 'adjustable_schema/active_record/association'
		autoload :Builder,     'adjustable_schema/active_record/builder'

		ActiveSupport.on_load :active_record do
			include Associations
			include Relationships
			include Actors
		end
	end
end
