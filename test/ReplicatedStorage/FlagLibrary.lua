return {
    LiveExperienceId = 4931500074,
    Flags = {
        ["SkipMenu"] = {
            Name = "Skip Menu",
            Description = "Immediately closes the menu upon joining for quicker testing.",
            OverrideEnvironments = {
                "Studio"
            },
            Tags = { },
            FallbackValue = false
        },
        ["GamepassOverride"] = {
            Name = "Gamepass Override",
            Description = "Ignores any gamepass requirements so you can test a gamepass feature without owning it.",
            OverrideEnvironments = {
                "Studio",
                "Testing"
            },
            Tags = { },
            FallbackValue = false
        }
    }
}