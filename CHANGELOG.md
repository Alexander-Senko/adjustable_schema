## [0.10.0] — UNRELEASED

### Changed

- No more polymorphic STI associations tricks.


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
