require "test_helper"
require 'minitest/autorun'

describe AdjustableSchema::Relationship do
	let(:described_class) { AdjustableSchema::Relationship }

	describe 'scopes' do
		before do
			@association_names = AdjustableSchema::Engine.config.names[:associations] # backup

			AdjustableSchema::Engine.config.names[:associations] = {
					source: { shortcut: 'src' },
					target: { shortcut: 'tgt' },
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
				@shortcuts              = nil
			end

			load AdjustableSchema::Engine.root / 'app/models/adjustable_schema/relationship.rb' # HACK: reload the model
		end

		it 'uses names from the config' do
			_(described_class).must_respond_to :src
			_(described_class).must_respond_to :tgt

			_(described_class.abstract).must_equal described_class
					.src(:abstract)
					.tgt(:abstract)
		end
	end

	describe '.seed!' do
		let(:last_seed) { described_class.last }

		it 'accepts model names' do
			described_class.seed! 'Model1', 'Model2'

			_ { last_seed.attributes.symbolize_keys => {
					source_type: 'Model1',
					source_id:   nil,
					target_type: 'Model2',
					target_id:   nil,
					role_id:     nil,
			} }.must_pattern_match
		end

		it 'accepts a Hash-like syntax' do
			described_class.seed! Model1 => Model2

			_ { last_seed.attributes.symbolize_keys => {
					source_type: 'Model1',
					source_id:   nil,
					target_type: 'Model2',
					target_id:   nil,
					role_id:     nil,
			} }.must_pattern_match
		end

		it 'accepts a single model' do
			described_class.seed! Model1

			_ { last_seed.attributes.symbolize_keys => {
					source_type: 'Model1',
					source_id:   nil,
					target_type: 'Model1',
					target_id:   nil,
					role_id:     nil,
			} }.must_pattern_match
		end

		it 'accepts roles' do
			described_class.seed! Model1 => Model2, roles: %w[ dummy_role ]

			_ { last_seed.attributes.symbolize_keys => {
					source_type: 'Model1',
					source_id:   nil,
					target_type: 'Model2',
					target_id:   nil,
			} }.must_pattern_match

			_(last_seed.name).must_equal 'dummy_role'
		end
	end

	describe '#name=' do
		subject { described_class.new name: role_name }

		let(:role_name) { :dummy_role }
		let(:role) { described_class::Role.find_or_create_by! name: role_name }

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
