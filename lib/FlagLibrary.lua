return {
    LiveExperienceId = game.GameId,
    Flags = {
        ["ExampleFlag"] = {
            Name = "Example Flag", -- The display name for this flag.
            Description = "This is an example flag, not meant to be used in any actual code.", -- The description for this flag, shown on the studio plugin.
            OverrideEnvironments = { -- In what environments the studio plugin override for this flag should be taken as the real value.
                "Studio",
                "Testing",
                "Live"
            },
            Tags = { }, -- Any additional tags to attach to this flag.
            FallbackValue = true -- The fallback value when no value is able to be fetched from the studio plugin overrides.
        }
    }
}