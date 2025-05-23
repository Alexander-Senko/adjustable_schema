## [0.12.0] — UNRELEASED

### Changed

- Removed deprecated `Relationship.seed!`.


## [0.11.1] — 2025-05-19

### Fixed

- Associations setup for inherited models got broken in v0.11.0.


## [0.11.0] — 2025-05-09

### Changed

- Deprecated `Relationship.seed!` in favor of `AdjustableSchema.relationship!`.
- Special naming rules for “actor-like” models:
	switched from `<associat>ful` form to check for related records’ presence back to a passive one (`<associat>ed`).
	Thus, it’s `authored` and `edited` now instead of `authorful` and `editful`.
- `Relationship.to`/`.of` handle STI classes precisely instead of falling back to a base class.
- Customized inspections for `Relationship`.

### Added

- `referencing`/`referenced_by` scopes to filter by related records.
- `#referencing!`/`#referenced_by!` setters to add related records.
- Short-cut methods for related records.
	For example, `authors` association provides the following extras:
	- `.authored_by` scope to filter records by authors,
	- `#authored_by?` — to check if the record is authored by provided ones,
	- `#authored_by!` — to add an author.


## [0.10.0] — 2025-04-23

### Changed

- No more polymorphic STI associations tricks (see 0dd30220 for details).

### Added

- Special naming rules for “actor-like” models.


## [0.9.0] — 2025-03-10

### Changed

- Requires Rails 8 and Ruby 3.4+.
- Protected `AdjustableSchema::Relationship::Role` from being deleted when used.

### Added

- `Relationship#sourced` and `Relationship#targeted` scopes to filter relationships by presence of _source_ and _target_ records respectively.

### Fixed

- `Relationship#applied` scope used to return relationships with at least one record attached, instead of ones with both records present.


## [0.8.0] — 2024-11-08

### Changed

- Renamed checks for related records:
	`<associat>ful` form is now used instead of a passive one (`<associat>ed`) to check for related records’ presence.
	- `.<associat>ful` — scope records having associated ones.
	- `#<associat>ful?` — are there any records associated?
- Naming: improved passive forms for words ending with `or`/`ant`/`ion`/`ment`/`ing`.

### Added

- Checks for related records’ presence on roleless recursive associations:
	- `.<associat>ful` —
		records having associated ones;
	- `.<association>less` —
		records not having associated ones;
	- `#<associat>ful?` —
		if there are records associated;
	- `#<association>less?` —
		if there are no records associated;
	- `#intermediate?` —
		whether is only one child record associated (_Is the node just a link between two other nodes like?_);
	- `#branching?` —
		whether are several child records associated.

### Fixed

- Naming: passive form for `author`.


## [0.7.2] — 2024-04-02

### Fixed

- `roleless` scope used to generate wrong queries.


## [0.7.1] — 2024-03-31

### Fixed

- DB constraints:
	- `roles.name` is `NOT NULL`,
	- `UNIQUE` constraints should treat `NULLS` as `NOT DISTINCT`.
- Roleless recursive associations used to fail on `joins`.


## [0.7.0] — 2024-02-25

### Changed

- Naming: improved passive forms a bit.
- Configuration: renamed `self_related` to `self`.

### Added

- Checks for related records’ presence:
	- `.<associat>ed` —
		records having associated ones;
	- `.<association>less` —
		records not having associated ones;
	- `#<associat>ed?` —
		if there are records associated;
	- `#<association>less?` —
		if there are no records associated.
- Documentation: self-targeted relationships in README.

### Fixed

- Documentation: examples in the README.


## [0.6.0] — 2024-02-20

### Changed

- Destroy orphaned relationships of an object on destroy.
- Symbolize configurable names used for associations, methods, etc.
- Raise `ArgumentError` for unknown names passed to the API.

### Added

- `Relationship[]` to filter relationships by related objects/classes.
- `Role[]` accepts `Hash`-like parameters to filter roles by relationships.
- Methods for related records:
	- `related?` to check for related objects,
	- `related` to fetch them,
	- and the basic `relationships`.
- Recursive methods for related records:
	- flat `ancestors` & `descendants` with distance,
	- based on `recursive` association scope.
- `roleless` scope for related records without a role.
- A dedicated association for roleless children.

### Fixed

- Faulty scopes in role-based relationship associations.
- Naming for namespaced models, e.g., in Rails Engines.


## [0.5.0] — 2023-12-29

Refactored from [Rails Dynamic Associations](
	https://github.com/Alexander-Senko/rails_dynamic_associations
).

Some experimental features are missing and can be found in the `api` branch.
