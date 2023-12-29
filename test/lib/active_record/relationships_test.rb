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
				_(subject.map &:target)
						.must_equal [ target, target_r1 ]
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

		describe 'recursive methods' do
			before do
				(5 - Model1.count).times { Model1.create! }

				Model1.first .from_selves = [ Model1.second, Model1.third  ]
				Model1.second.from_selves = [ Model1.fourth, Model1.fifth  ]
				Model1.third .from_selves = [ Model1.second, Model1.fourth ]
			end

			describe '#descendants' do
				let(:method_name) { :from_recursive }
				let(:source)      { Model1.first }

				subject { source.send method_name }

				it('is defined') { _(source).must_respond_to method_name }

				it 'returns related records' do
					_(subject)
							.must_be_kind_of ::ActiveRecord::Relation
					_(subject.pluck :id)
							.must_equal [ # distinct
									Model1.second,
									Model1.third,
									Model1.fourth,
									Model1.fifth,
							].map &:id
					_(subject.to_a)
							.must_equal [
									Model1.second,
									Model1.third,
									Model1.fourth,
									Model1.fifth,
									Model1.second,
									Model1.fourth,
									Model1.fifth,
							]
				end

				it 'returns distance' do
					_(subject.pluck :id, :distance)
							.must_equal [
									[ Model1.second.id, 1 ],
									[ Model1.third .id, 1 ],
									[ Model1.fourth.id, 2 ],
									[ Model1.fifth .id, 2 ],
									[ Model1.second.id, 2 ],
									[ Model1.fourth.id, 3 ],
									[ Model1.fifth .id, 3 ],
							]
					_(subject.pluck :distance)
							.must_equal [ 1, 2, 3 ] # distinct
					_(subject.map &:distance)
							.must_equal [ 1, 1, 2, 2, 2, 3, 3 ]
				end

				describe 'without children' do
					let(:source) { Model1.fourth }

					it 'returns nothing' do
						_(subject)
								.must_be_kind_of ::ActiveRecord::Relation
						_(subject)
								.must_be_empty
					end
				end

				describe 'when not self-targeted' do
					it("isn't defined") { _(Model2.new).wont_respond_to method_name }
				end
			end

			describe '#ancestors' do
				let(:method_name) { :to_recursive }
				let(:source)      { Model1.fourth }

				subject { source.send method_name }

				it('is defined') { _(source).must_respond_to method_name }

				it 'returns related records' do
					_(subject)
							.must_be_kind_of ::ActiveRecord::Relation
					_(subject.pluck :id)
							.must_equal [ # distinct
									Model1.second,
									Model1.third,
									Model1.first,
							].map &:id
					_(subject.to_a)
							.must_equal [
									Model1.second,
									Model1.third,
									Model1.first,
									Model1.third,
									Model1.first,
							]
				end

				it 'returns distance' do
					_(subject.pluck :id, :distance)
							.must_equal [
									[ Model1.second.id, 1 ],
									[ Model1.third .id, 1 ],
									[ Model1.first .id, 2 ],
									[ Model1.third .id, 2 ],
									[ Model1.first .id, 3 ],
							]
					_(subject.pluck :distance)
							.must_equal [ 1, 2, 3 ] # distinct
					_(subject.map &:distance)
							.must_equal [ 1, 1, 2, 2, 3 ]
				end

				describe 'without parents' do
					let(:source) { Model1.first }

					it 'returns nothing' do
						_(subject)
								.must_be_kind_of ::ActiveRecord::Relation
						_(subject)
								.must_be_empty
					end
				end

				describe 'when not self-targeted' do
					it("isn't defined") { _(Model2.new).wont_respond_to method_name }
				end
			end
		end
	end
end
