# frozen_string_literal: true

case Rails.version
when ('8.2'...)
	Arel::Table.prepend Module.new { # HACK: dual-API
		def initialize(name = nil, **) = super(name:, **)
	}
end
