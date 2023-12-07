Gem::Author ||= Struct.new(
		:name,
		:email,
		:github_url,
)

module AdjustableSchema
	AUTHORS = [
			Gem::Author.new(
					name:       'Alexander Senko',
					email:      'Alexander.Senko@gmail.com',
					github_url: 'https://github.com/Alexander-Senko',
			),
	]
end
