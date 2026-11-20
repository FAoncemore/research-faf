local EXPAlert = import('/mods/Research FAF/lua/ui/IntelPanel.lua')

#economy balance exchange ON/OFF
table.insert(options.ui.items, {
	title = "<LOC OPT_Research_ECO_EX_Toggle>Research FAF Eco Balance turn off if Paragon",
	key = "Research_eco_bal_ex",
	type = 'toggle',
	default = true,
    set = function(key, value, startup)
		SimCallback({Func = 'EcoBalExUIToggle', Args = value})
    end,
	custom = {
		states = {
			{text = "<LOC _No>", key = false },
			{text = "<LOC _Yes>", key = true },
		},
	},
})