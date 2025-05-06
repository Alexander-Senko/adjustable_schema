AdjustableSchema::Engine.config.names[:associations].deep_merge!(
		source: {
				shortcut:  'f',
				self:      'from_self',
				recursive: 'from_recursive',
		},
		target: {
				shortcut:  't',
				self:      'to_self',
				recursive: 'to_recursive',
		},
)
