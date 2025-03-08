# frozen_string_literal: true

ActiveSupport.on_load :model_class do
	next if     self == AdjustableSchema::Relationship
	next unless AdjustableSchema.available?

	adjust_associations
end
