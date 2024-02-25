require "test_helper"
require 'minitest/autorun'

require 'adjustable_schema/active_record/association'

module AdjustableSchema
	describe ActiveRecord::Association do
		let(:described_class) { ActiveRecord::Association }

		subject { described_class.new owner, direction, target, role }

		let(:direction) { :target }
		let(:owner)     { Model1 }
		let(:target)    { Model2 }
		let(:role)      { Relationship::Role.find_or_create_by! name: role_name }
		let(:role_name) { :dummy_role }
		let(:record)    { subject.owner.create! }

		describe '#define' do
			let(:associated_with_role_method_name) { "#{subject.name}_with_roles" }
			let(:name_for_any)                     { "#{subject.name.to_s.singularize}ed" }
			let(:name_for_none)                    { "#{subject.name.to_s.singularize}less" }

			before { subject.define }

			it 'defines an association' do
				_(owner.reflect_on_association subject.name)
						.wont_be_nil
				_(record.send(subject.name).to_a)
						.must_be_kind_of Array
			end

			it 'defines scopes' do
				_(owner).must_respond_to name_for_any
				_(owner).must_respond_to name_for_none
			end

			it 'defines methods' do
				_(record).must_respond_to "#{name_for_any}?"
				_(record).must_respond_to "#{name_for_none}?"
			end

			it 'defines association scopes' do
				_(record.send subject.name)
						.wont_respond_to :recursive
				_(target.all)
						.wont_respond_to :recursive
			end

			describe 'when self-targeted' do
				let(:target) { owner }

				it 'defines recursive association scopes' do
					_(record.send subject.name)
							.must_respond_to :recursive
					_(target.all)
							.wont_respond_to :recursive
				end
			end

			describe 'with a role' do
				it "doesn't define role methods" do
					_(record).wont_respond_to associated_with_role_method_name
				end
			end

			describe 'without a role' do
				let(:role) {}

				let(:associated_with_role) { record.send associated_with_role_method_name, role_name }

				it 'defines #<association>_with_roles' do
					_(record)
							.must_respond_to associated_with_role_method_name
					_(associated_with_role)
							.must_be_kind_of ::ActiveRecord::Relation
					_(associated_with_role.klass)
							.must_equal target

					associated_with_role
							.distinct.pluck('adjustable_schema_relationship_roles.name')
							.each { _(_1).must_equal role_name.to_s }
				end

				describe 'when self-targeted' do
					let(:target) { owner }

					let(:roleless_children_name) { owner.table_name }

					it 'defines an extra association for roleless children' do
						_(owner.reflect_on_association roleless_children_name)
								.wont_be_nil
						_(record.send(roleless_children_name).to_a)
								.must_be_kind_of Array
					end
				end
			end
		end
	end
end
