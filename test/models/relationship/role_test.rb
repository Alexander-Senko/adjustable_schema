require "test_helper"
require 'minitest/autorun'

module AdjustableSchema
	describe Relationship::Role do
		let(:described_class) { Relationship::Role }

		describe '.[]' do
			subject { described_class[*roles, **scopes] }

			let(:roles)  { [] }
			let(:scopes) { {} }

			describe 'with role names' do
				let(:roles) { %i[ role1 ] }

				it 'finds roles' do
					_(subject)
							.must_be_instance_of described_class
					_(subject.name)
							.must_equal 'role1'
				end
			end

			describe 'with related models' do
				let(:scopes) { { Model1 => Model2 } }

				it 'finds roles' do
					_(subject)
							.must_be_kind_of ::ActiveRecord::Relation
					_(subject.map(&:class).uniq)
							.must_equal [ described_class ]
					_(subject.names.sort)
							.must_equal %i[ role1 role2 ]
				end
			end

			describe 'with both role names and related models' do
				let(:roles)  { %i[ role1 ] }
				let(:scopes) { { Model1 => Model2 } }

				it 'finds roles' do
					_(subject)
							.must_be_instance_of described_class
					_(subject.name)
							.must_equal 'role1'
				end

				describe 'when missing' do
					let(:roles) { %i[ missing_role ] }

					it 'fails to find a role' do
						_ { subject }.must_raise ArgumentError
					end
				end
			end
		end
	end
end
