require "test_helper"
require 'minitest/autorun'

require 'adjustable_schema/active_record/association'

describe AdjustableSchema::ActiveRecord::Association::Naming do
	let(:described_class) { AdjustableSchema::ActiveRecord::Association }

	let(:source_association) { described_class.new owner, :source, target, role }
	let(:target_association) { described_class.new owner, :target, target, role }

	let(:owner)     { Model1 }
	let(:target)    { Model2 }
	let(:role)      { AdjustableSchema::Relationship::Role.find_or_create_by! name: role_name }
	let(:role_name) { :dummy_role }

	describe '#name' do
		describe 'with a role' do
			it 'names sources' do
				_(source_association.name).must_equal :dummy_role_model2s
			end

			it 'names targets' do
				_(target_association.name).must_equal :dummy_roled_model2s
			end

			describe 'when self-targeted' do
				let(:target) { owner }

				it 'names sources' do
					_(source_association.name).must_equal :dummy_roles
				end

				it 'names targets' do
					_(target_association.name).must_equal :dummy_roled_model1s
				end
			end
		end

		describe 'without a role' do
			let(:role) {}

			it 'names sources' do
				_(source_association.name).must_equal :model2s
			end

			it 'names targets' do
				_(target_association.name).must_equal :model2s
			end

			describe 'when self-targeted' do
				let(:target) { owner }

				before do
					@association_names = AdjustableSchema::Engine.config.names[:associations] # backup

					AdjustableSchema::Engine.config.names[:associations] = {
							source: { self_related: 'from_self' },
							target: { self_related:   'to_self' },
					}

					reload!
				end

				after do
					AdjustableSchema::Engine.config.names[:associations] = @association_names # restore

					reload!
				end

				def reload!
					AdjustableSchema::Config.instance_eval do # HACK: invalidate caches
						@association_directions = nil
					end
				end

				it 'names sources' do
					_(source_association.name).must_equal :from_selves
				end

				it 'names targets' do
					_(target_association.name).must_equal :to_selves
				end
			end
		end
	end

	describe '#relationships_name' do
		describe 'with a role' do
			it 'names sources' do
				_(source_association.relationships_name).must_equal :dummy_role_model2_relationships
			end

			it 'names targets' do
				_(target_association.relationships_name).must_equal :dummy_roled_model2_relationships
			end

			describe 'when self-targeted' do
				let(:target) { owner }

				it 'names sources' do
					_(source_association.relationships_name).must_equal :dummy_role_relationships
				end

				it 'names targets' do
					_(target_association.relationships_name).must_equal :dummy_roled_model1_relationships
				end
			end
		end

		describe 'without a role' do
			let(:role) {}

			it 'names sources' do
				_(source_association.relationships_name).must_equal :source_relationships
			end

			it 'names targets' do
				_(target_association.relationships_name).must_equal :target_relationships
			end
		end
	end
end
