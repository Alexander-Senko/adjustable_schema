class CreateAdjustableSchemaRelationshipTables < ActiveRecord::Migration[7.1]
	def change
		# Use Active Record's configured type for primary and foreign keys
		primary_key_type, foreign_key_type = primary_and_foreign_key_types

		create_table :adjustable_schema_relationship_roles do |t|
			t.string :name, null: false, index: { unique: true }

			t.timestamps
		end

		create_table :adjustable_schema_relationships do |t|
			t.references :source, polymorphic: true, index: true, type: foreign_key_type
			t.references :target, polymorphic: true, index: true, type: foreign_key_type
			t.references :role,                      index: true,
					foreign_key: { to_table: :adjustable_schema_relationship_roles }

			t.timestamps

			%i[
					source_id source_type
					target_id target_type
					role_id
			].tap { |columns|
				columns.reject! { _1.ends_with? '_type' } if foreign_key_type == :uuid # OPTIMIZATION: IDs are unique

				# NULLS are DISTINCT by default.
				# One can use `ADD CONSTRAINT … UNIQUE NULLS NOT DISTINCT (…)` instead
				t.index columns,
						unique: true, where: 'role_id IS NOT NULL', name: :index_adjustable_schema_relationships_uniqueness_with_role
				t.index columns.without(:role_id),
						unique: true, where: 'role_id IS     NULL', name: :index_adjustable_schema_relationships_uniqueness_without_role
			}
		end
	end

	private

	def primary_and_foreign_key_types
		config           = Rails.configuration.generators
		setting          = config.options[config.orm][:primary_key_type]
		primary_key_type = setting || :primary_key
		foreign_key_type = setting || :bigint
		[primary_key_type, foreign_key_type]
	end
end
