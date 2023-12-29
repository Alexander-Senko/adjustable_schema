require "test_helper"
require 'minitest/autorun'

require 'adjustable_schema/active_record/association'

describe AdjustableSchema::ActiveRecord::Association do
	let(:described_class) { AdjustableSchema::ActiveRecord::Association }

	subject { described_class.new Model1, direction, target, role }

	let(:direction) { :target }
	let(:target)    { Model2 }
	let(:role)      { AdjustableSchema::Relationship::Role.find_or_create_by! name: role_name }
	let(:role_name) { :dummy_role }
	let(:record)    { subject.owner.create! }

	describe '#define' do
		let(:associated_with_role_method_name) { "#{subject.name}_with_roles" }

		before { subject.define }

		it 'defines an association' do
			_(subject.owner.reflect_on_association subject.name).wont_be_nil
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
				_(record                    ).must_respond_to associated_with_role_method_name
				_(associated_with_role      ).must_be_kind_of ActiveRecord::Relation
				_(associated_with_role.klass).must_equal      target

				associated_with_role
						.distinct.pluck('adjustable_schema_relationship_roles.name')
						.each { _(_1).must_equal role_name.to_s }
			end
		end
	end
end
