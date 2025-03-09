# frozen_string_literal: true

module AdjustableSchema
	module ActiveRecord
		module Association::Roleless # :nodoc:
			def define
				super

				has_many roleless_name, -> { roleless }, **options if
						child?
			end

			private

			def define_methods
				super

				name = self.name # save the context

				owner.redefine_method "#{name}_with_roles" do |*roles|
					send(name)
							.merge Relationship.named *roles
				end
			end
		end
	end
end
