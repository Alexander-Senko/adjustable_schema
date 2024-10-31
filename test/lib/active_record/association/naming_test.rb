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

			describe 'when recursive' do
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

			describe 'when recursive' do
				let(:target) { owner }

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

			describe 'when recursive' do
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

	describe 'String#passivise' do
		using AdjustableSchema::ActiveRecord::Association::Inflections

		def passivize(string) = string.passivize

		it { _(passivize 'parent'     ).must_equal 'parented'   }
		it { _(passivize 'name'       ).must_equal 'named'      }
		it { _(passivize 'user'       ).must_equal 'used'       }
		it { _(passivize 'mentor'     ).must_equal 'mentored'   }
		it { _(passivize 'director'   ).must_equal 'directed'   }
		it { _(passivize 'author'     ).must_equal 'authored'   }
		it { _(passivize 'editor'     ).must_equal 'edited'     }
		it { _(passivize 'edition'    ).must_equal 'edited'     }
		it { _(passivize 'translator' ).must_equal 'translated' }
		it { _(passivize 'translation').must_equal 'translated' }
		it { _(passivize 'version'    ).must_equal 'versioned'  }
		it { _(passivize 'tenant'     ).must_equal 'tenanted'   }
		it { _(passivize 'relaxant'   ).must_equal 'relaxed'    }
		it { _(passivize 'segment'    ).must_equal 'segmented'  }
		it { _(passivize 'enchantment').must_equal 'enchanted'  }
		it { _(passivize 'improvement').must_equal 'improved'   }
		it { _(passivize 'ping'       ).must_equal 'pinged'     }
		it { _(passivize 'rating'     ).must_equal 'rated'      }
		it { _(passivize 'processing' ).must_equal 'processed'  }
		it { _(passivize ''           ).must_equal ''           }
	end
end
