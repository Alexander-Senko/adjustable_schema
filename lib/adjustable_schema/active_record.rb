# frozen_string_literal: true

module AdjustableSchema
	module ActiveRecord # :nodoc:
		autoload :Association, 'adjustable_schema/active_record/association'

		ActiveSupport.on_load :active_record do
			include Associations
			include Relationships
		end
	end
end
