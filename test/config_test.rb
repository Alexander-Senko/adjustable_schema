# frozen_string_literal: true

# Enhanced table view for hashes
#
# rubocop:disable Layout/HashAlignment
# rubocop:disable Layout/ArgumentAlignment
# rubocop:disable Layout/IndentationStyle

require 'test_helper'
require 'minitest/autorun'

describe AdjustableSchema::Config do
	let(:described_class) { AdjustableSchema::Config }

	describe '.association_directions' do
		subject { described_class.association_directions }

		it 'returns names' do
			_(subject).must_equal %i[ source target ]
		end

		describe '.shortcuts' do
			it 'returns names' do
				_(subject.shortcuts).must_equal(
						source: :f,
						target: :t,
				)
			end
		end

		describe '.shortcuts.opposite' do
			it 'returns names' do
				_(subject.shortcuts.opposite).must_equal(
						source: :t,
						target: :f,
				)
			end

			it 'returns a shortcut when called with `to:`' do
				_(subject.shortcuts.opposite to: :f).must_equal :t
			end

			it 'raises on invalid names' do
				_ { subject.shortcuts.opposite to: :of }.must_raise Enumerable::SoleItemExpectedError
			end
		end

		describe '.self' do
			it 'returns names' do
				_(subject.self).must_equal(
						source: :from_self,
						target:   :to_self,
				)
			end
		end

		describe '.references' do
			it 'returns names' do
				_(subject.references).must_equal(
						source: :referenced_by,
						target: :referencing,
				)
			end
		end

		describe '.recursive' do
			it 'returns names' do
				_(subject.recursive).must_equal(
						from_selves: :from_recursive,
						  to_selves:   :to_recursive,
				)
			end
		end

		describe '.opposite' do
			it 'returns a name' do
				_(subject.opposite to: :source).must_equal :target
				_(subject.opposite to: :target).must_equal :source
			end

			it 'raises on invalid names' do
				_ { subject.opposite to: :from }.must_raise Enumerable::SoleItemExpectedError
			end
		end

		describe '.with_opposite' do
			it 'returns a name mapping' do
				_(subject.with_opposite).must_equal(
						source: :target,
						target: :source,
				)
			end
		end
	end

	describe '.find_direction' do
		it 'finds existing' do
			_(described_class.find_direction source: :x).must_equal %i[ source x ]
		end

		it 'finds by shortcut' do
			_(described_class.find_direction f: :x).must_equal %i[ source x ]
		end

		it 'raises on invalid names' do
			_ { described_class.find_direction from: :x }.must_raise ArgumentError
		end
	end
end
