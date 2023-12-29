module AdjustableSchema
	module ActiveRecord
		autoload :Association, 'adjustable_schema/active_record/association'

		ActiveSupport.on_load :active_record do
			include Associations
			include Relationships
		end
	end
end
