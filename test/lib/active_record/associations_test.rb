require "test_helper"
require 'minitest/autorun'

describe AdjustableSchema::ActiveRecord::Associations do
	it 'defines associations' do
		AdjustableSchema::Relationship.seed! 'Model1', 'Model2'

		_(Model1.new).must_respond_to :model2s
		_(Model2.new).must_respond_to :model1s
	end
end
