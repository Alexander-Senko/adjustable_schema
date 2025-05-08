# frozen_string_literal: true

# rubocop:disable Layout/MultilineBlockLayout
# rubocop:disable Layout/BlockEndNewline

require 'test_helper'
require 'minitest/autorun'

describe AdjustableSchema do
	subject { AdjustableSchema }

	it 'should be available' do
		_(subject).must_be :available?
	end

	describe '.relationship!' do
		let(:last_seed) { AdjustableSchema::Relationship.last }

		after { last_seed.destroy }

		it 'accepts model names' do
			subject.relationship! 'Model1', 'Model2'

			_ { last_seed.attributes.symbolize_keys => {
					source_type: 'Model1',
					source_id:   nil,
					target_type: 'Model2',
					target_id:   nil,
					role_id:     nil,
			} }.must_pattern_match
		end

		it 'accepts a Hash-like syntax' do
			subject.relationship! Model1 => Model2

			_ { last_seed.attributes.symbolize_keys => {
					source_type: 'Model1',
					source_id:   nil,
					target_type: 'Model2',
					target_id:   nil,
					role_id:     nil,
			} }.must_pattern_match
		end

		it 'accepts a single model' do
			subject.relationship! Model1

			_ { last_seed.attributes.symbolize_keys => {
					source_type: 'Model1',
					source_id:   nil,
					target_type: 'Model1',
					target_id:   nil,
					role_id:     nil,
			} }.must_pattern_match
		end

		it 'accepts roles' do
			subject.relationship! Model1 => Model2, roles: %w[ dummy_role ]

			_ { last_seed.attributes.symbolize_keys => {
					source_type: 'Model1',
					source_id:   nil,
					target_type: 'Model2',
					target_id:   nil,
			} }.must_pattern_match

			_(last_seed.name).must_equal 'dummy_role'
		end
	end
end
