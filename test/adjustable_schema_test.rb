# frozen_string_literal: true

require 'test_helper'
require 'minitest/autorun'

describe AdjustableSchema do
	subject { AdjustableSchema }

	it 'should be available' do
		_(subject).must_be :available?
	end
end
