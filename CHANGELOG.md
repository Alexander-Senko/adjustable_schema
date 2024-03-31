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
		records having associated ones,
	- `.<association>less` —
		records not having associated ones,
	- `#<associat>ed?` —
		if there are records associated,
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
