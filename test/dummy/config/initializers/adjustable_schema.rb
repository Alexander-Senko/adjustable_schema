AdjustableSchema::Engine.config.names[:associations] = {
		source: {
				shortcut:     'f',
				self_related: 'from_self',
				recursive:    'from_recursive',
		},
		target: {
				shortcut:     't',
				self_related: 'to_self',
				recursive:    'to_recursive',
		},
}
