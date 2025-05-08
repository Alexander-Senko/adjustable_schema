# frozen_string_literal: true

require 'adjustable_schema/version'
require 'adjustable_schema/engine'
require 'adjustable_schema/active_record'

require 'rails_model_load_hook' # should be loaded

module AdjustableSchema # :nodoc:
	autoload :Config, 'adjustable_schema/config'

	extend ActiveRecord::Builder

	module_function

	def available?
		Relationship.table_exists?
	end

	def deprecator # :nodoc:
		@deprecator ||= ActiveSupport::Deprecation.new
	end
end
