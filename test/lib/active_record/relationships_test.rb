require "test_helper"
require 'minitest/autorun'

module AdjustableSchema
	describe ActiveRecord::Relationships do
		let(:source)     { Model1.create! }
		let(:target)     { source.model2s.create! }
		let(:target_r1)  { source.role1ed_model2s.create! }
		let(:role_names) { %i[ role1 role2 ] }

		before do # should exist
			target
			target_r1
		end

		describe '#related?' do
			it 'checks if there are any related records' do
				_(source.related?)
						.must_equal true
				_(source.related? target: Model2)
						.must_equal true
				_(source.related? target: Model1)
						.must_equal false
				_(source.related? source: Model2)
						.must_equal false
			end
		end

		describe '#related' do
			subject { source.related }

			it 'returns related records' do
				_(subject)
						.must_equal [ target, target_r1 ]
			end
		end

		describe '#relationships' do
			subject { source.relationships }

			it 'returns relationships' do
				_(subject)
						.must_be_kind_of ::ActiveRecord::Relation
				_(subject.map(&:target))
						.must_equal [target, target_r1]
			end

			describe 'with options' do
				subject { source.relationships t: target_r1 }

				it 'filters by related objects' do
					_(subject)
							.must_be_kind_of ::ActiveRecord::Relation
					_(subject.sole.target)
							.must_equal target_r1
				end
			end
		end
	end
end
