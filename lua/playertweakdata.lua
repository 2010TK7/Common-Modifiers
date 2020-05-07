if not CommonModifiers.Checker then
	return
end

local _CM = CommonModifiers.settings

Hooks:PostHook(PlayerTweakData, "init", "CM_init", function(self)
	CommonModifiers:Load()
	if _CM.OM_pagers_1 then
		table.remove(self.alarm_pager.bluff_success_chance, 1)
	end
	if _CM.OM_pagers_2 then
		table.remove(self.alarm_pager.bluff_success_chance, 1)
	end
	if _CM.OM_pagers_3 then
		table.remove(self.alarm_pager.bluff_success_chance, 1)
	end
	if _CM.OM_pagers_4 then
		table.remove(self.alarm_pager.bluff_success_chance, 1)
	end
end)