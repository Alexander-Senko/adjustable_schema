# frozen_string_literal: true

require 'test_helper'
require 'minitest/autorun'

require 'adjustable_schema/active_record/association'

module AdjustableSchema
	describe ActiveRecord::Association do
		let(:described_class) { ActiveRecord::Association }

		subject { described_class.new owner, direction, target, role }

		let(:direction) { :target }
		let(:owner)     { Model1 }
		let(:target)    { Model2 }
		let(:role)      { AdjustableSchema.role! role_name }
		let(:role_name) { :dummy_role }
		let(:record)    { subject.owner.create! }

		describe '#define' do
			let(:association_name)                 { subject.name }
			let(:associated_with_role_method_name) { "#{association_name}_with_roles" }
			let(:name_for_any)                     { "#{association_name.to_s.singularize}ful" }
			let(:name_for_none)                    { "#{association_name.to_s.singularize}less" }

			before { subject.define }

			using Module.new { # shared examples
				refine Minitest::Spec.singleton_class do
					def defines_association(&)
						it 'defines an association' do
							_(owner.reflect_on_association association_name)
									.wont_be_nil
							_(record.send(association_name).to_a)
									.must_be_kind_of Array
						end
					end

					def defines_scopes(&)
						it 'defines scopes' do
							_(owner).must_respond_to name_for_any
							_(owner).must_respond_to name_for_none

							instance_eval(&) if block_given?
						end
					end

					def defines_methods(&)
						it 'defines methods' do
							_(record).must_respond_to "#{name_for_any}?"
							_(record).must_respond_to "#{name_for_none}?"

							instance_eval(&) if block_given?
						end
					end
				end
			}

			defines_association
			defines_scopes
			defines_methods

			it 'defines association scopes' do
				_(record.send association_name)
						.wont_respond_to :recursive
				_(target.all)
						.wont_respond_to :recursive
			end

			describe 'with an actor-like model' do
				let(:direction) { :source }
				let(:target)    { User }
				let(:role_name) { :author }

				let(:association_name) { 'authors' }
				let(:name_for_any)     { 'authored' }

				defines_scopes do
					_(owner).must_respond_to :authored_by
				end

				defines_methods do
					_(record).must_respond_to :authored_by?
					_(record).must_respond_to :authored_by!
				end

				describe 'without a role' do
					let(:role) {}

					let(:association_name) { 'users' }
					let(:name_for_any)     { 'used' }

					defines_scopes do
						_(owner).wont_respond_to :used_by
					end

					defines_methods do
						_(record).wont_respond_to :used_by?
						_(record).wont_respond_to :used_by!
					end
				end
			end

			describe 'when recursive' do
				let(:target) { owner }

				it 'defines recursive association scopes' do
					_(record.send association_name)
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
							.each { _(it).must_equal role_name.to_s }
				end

				describe 'when recursive' do
					let(:target) { owner }

					describe 'for roleless children' do
						let(:association_name) { owner.table_name }

						defines_association

						defines_scopes do
							skip 'not yet implemented'

							_(owner).must_respond_to :intermediate
							_(owner).must_respond_to :branching
						end

						defines_methods do
							_(record).must_respond_to :intermediate?
							_(record).must_respond_to :branching?
						end
					end
				end
			end
		end
	end
end
