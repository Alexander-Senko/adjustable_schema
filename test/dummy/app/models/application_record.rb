# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
	primary_abstract_class

	def inspect = [ self.class, id ] * '#'
end
