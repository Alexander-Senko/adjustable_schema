# frozen_string_literal: true

require 'test_helper'
require 'minitest/autorun'

module AdjustableSchema
	describe Relationship do
		let(:described_class) { Relationship }

		describe 'scopes' do
			it 'uses names from the config' do
				_(described_class).must_respond_to :f
				_(described_class).must_respond_to :t

				_(described_class.abstract).must_equal described_class
						.f(:abstract)
						.t(:abstract)
			end
		end

		describe '.[]' do
			subject { described_class[Model1 => Model2] }

			it 'filters relationships by related objects' do
				_(subject)
						.must_be_kind_of ::ActiveRecord::Relation
				_(subject.map(&:class).uniq)
						.must_equal [ described_class ]
				_(subject.distinct.pluck :source_type, :target_type)
						.must_equal [ %w[ Model1 Model2 ] ]
			end
		end

		describe '#name=' do
			subject { described_class.new name: role_name }

			let(:role_name) { :dummy_role }
			let(:role)      { AdjustableSchema.role! role_name }

			before { role } # should exist

			it 'sets the role by name' do
				_(subject.role).must_equal role
			end

			it 'unsets the role with `nil`' do
				_(subject.role).must_equal role

				subject.name = nil

				_(subject.role).must_be_nil
			end

			it 'raises on invalid names' do
				_ { described_class.new name: :x }.must_raise ArgumentError
			end
		end
	end
end
