# frozen_string_literal: true

# HACK: non-public Rails API used
ActiveModel::Name.class_eval do
	def unnamespaced = @unnamespaced || name
end
