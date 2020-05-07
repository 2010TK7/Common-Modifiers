if not CommonModifiers.Checker then
	return
end

local _CM = CommonModifiers.settings

Hooks:PostHook(PlayerTweakData, "init", "CM_init", function(self)
	CommonModifiers:Load()
	self.alarm_pager.bluff_success_chance = _CM.OM_pagers_4 and {0} or _CM.OM_pagers_3 and {1, 0} or _CM.OM_pagers_2 and {1, 1, 0} or _CM.OM_pagers_1 and {1, 1, 1, 0} or {1, 1, 1, 1, 0}
end)