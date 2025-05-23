# frozen_string_literal: true

# Enhanced table view for expressions
#
# rubocop:disable Layout/SpaceAroundMethodCallOperator

require 'test_helper'
require 'minitest/autorun'

module AdjustableSchema
	describe ActiveRecord::Relationships do
		let(:source)     { Model1.first_or_create! }
		let(:target)     { source.model2s.first_or_create! }
		let(:target_r1)  { source.role1ed_model2s.first_or_create! }
		let(:role_names) { %i[ role1 role2 ] }

		before do # should exist
			target
			target_r1
		end

		# HACK: looks like a bug in Rails
		ActiveRecord::Relationships::InstanceMethods.prepend Module.new {
			def relationships(...)
				warn <<~TEXT
					Reloading relationships to work around a possible bug in Rails.
					Remove this hack from #{__FILE__}:#{__LINE__} when the bug is fixed.
				TEXT

				super.tap { it.each &:reload }
			end
		}

		describe 'scopes' do
			describe '.referencing' do
				subject { receiver.referencing records, **options }

				let(:receiver) { target.model1s }
				let(:options)  {}

				describe 'with a record' do
					let(:records) { target }

					it 'returns records' do
						_(subject)
								.must_be_kind_of ::ActiveRecord::Relation
						_(subject)
								.must_include source
					end
				end

				describe 'with a class' do
					let(:records) { target.class }

					it 'returns records' do
						_(subject)
								.must_be_kind_of ::ActiveRecord::Relation
						_(subject)
								.must_include source
					end
				end

				describe 'with roles' do
					let(:records) { target.class }
					let(:options) { { role: } }

					describe 'with a single one' do
						let(:role) { role_names.first }

						it 'returns records' do
							_(subject)
									.must_be_kind_of ::ActiveRecord::Relation
							_(subject)
									.must_include source
						end

						describe 'with a missing one' do
							let(:role) { :missing }

							it 'returns nothing' do
								_(subject)
										.must_be_kind_of ::ActiveRecord::Relation
								_(subject)
										.must_be_empty
							end
						end
					end

					describe 'with several ones' do
						let(:role) { role_names }

						it 'returns records' do
							_(subject)
									.must_be_kind_of ::ActiveRecord::Relation
							_(subject)
									.must_include source
						end
					end
				end
			end

			describe '.referenced_by' do
				subject { receiver.referenced_by records, **options }

				let(:receiver) { source.model2s }
				let(:options)  {}

				describe 'with a record' do
					let(:records) { source }

					it 'returns records' do
						_(subject)
								.must_be_kind_of ::ActiveRecord::Relation
						_(subject)
								.must_include target, target_r1
					end
				end

				describe 'with a class' do
					let(:records) { source.class }

					it 'returns records' do
						_(subject)
								.must_be_kind_of ::ActiveRecord::Relation
						_(subject)
								.must_include target, target_r1
					end
				end

				describe 'with roles' do
					let(:records) { source.class }
					let(:options) { { role: } }

					describe 'with a single one' do
						let(:role) { role_names.first }

						it 'returns records' do
							_(subject)
									.must_be_kind_of ::ActiveRecord::Relation
							_(subject)
									.must_include target_r1
							_(subject)
									.wont_include target
						end

						describe 'with a missing one' do
							let(:role) { :missing }

							it 'returns nothing' do
								_(subject)
										.must_be_kind_of ::ActiveRecord::Relation
								_(subject)
										.must_be_empty
							end
						end
					end

					describe 'with an undefined one' do
						let(:role) {}

						it 'returns records' do
							_(subject)
									.must_be_kind_of ::ActiveRecord::Relation
							_(subject)
									.must_include target
							_(subject)
									.wont_include target_r1
						end
					end

					describe 'with several ones' do
						let(:role) { role_names }

						it 'returns records' do
							_(subject)
									.must_be_kind_of ::ActiveRecord::Relation
							_(subject)
									.must_include target_r1
							_(subject)
									.wont_include target
						end
					end
				end
			end
		end

		describe '#related?' do
			before do
				source.related
						.without(source, target, target_r1)
						.each &:destroy!
				source.relationships(source:)
						.each &:destroy!
			end

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
						.must_include target, target_r1
			end
		end

		describe '#relationships' do
			subject { source.relationships }

			it 'returns relationships' do
				_(subject)
						.must_be_kind_of ::ActiveRecord::Relation
				_(subject.map &:target)
						.must_include target, target_r1
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

		describe 'setters' do
			let(:record) { association.klass.create! }

			describe '#referencing!' do
				subject { source.referencing! record }

				let(:association) { source.model2s }

				it 'links the record' do
					subject

					_(association.reload)
							.must_include record
				end

				it 'doesn’t update the association' do
					association.load

					subject

					_(association)
							.wont_include record
				end

				it 'ignores duplicates' do
					2.times { subject }

					_(association.reload & [ record ])
							.must_be :one?
				end
			end

			describe '#referenced_by!' do
				subject { target.referenced_by! record }

				let(:association) { target.model1s }

				it 'links the record' do
					subject

					_(association.reload)
							.must_include record
				end

				it 'doesn’t update the association' do
					association.load

					subject

					_(association)
							.wont_include record
				end

				it 'ignores duplicates' do
					2.times { subject }

					_(association.reload & [ record ])
							.must_be :one?
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

				describe 'when not recursive' do
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

				describe 'when not recursive' do
					it("isn't defined") { _(Model2.new).wont_respond_to method_name }
				end
			end
		end
	end
end
