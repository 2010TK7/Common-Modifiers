if UnitedOffensive or not CommonModifiers.Checker then
	return
end

local _CM = CommonModifiers.settings

Hooks:PostHook(GroupAITweakData, "_init_unit_categories", "CM_init_unit_categories", function(self, difficulty_index)
	CommonModifiers:Load()

	if _CM.CM_BlackDozer and difficulty_index <= 4 then
		table.insert(self.unit_categories.FBI_tank.unit_types.america, Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"))
		table.insert(self.unit_categories.FBI_tank.unit_types.russia, Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"))
		table.insert(self.unit_categories.FBI_tank.unit_types.zombie, Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"))
		table.insert(self.unit_categories.FBI_tank.unit_types.murkywater, Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"))
	end

	if _CM.OM_heavies then
		for group, unit_group in pairs(self.unit_categories) do
			if unit_group.unit_types then
				for continent, units in pairs(unit_group.unit_types) do
					for i, unit_id in ipairs(units) do
						for swap_id, new_id in pairs(CommonModifiers.unit_swaps) do
							if unit_id == Idstring(swap_id) then
								units[i] = Idstring(new_id)

								break
							end
						end
					end
					end
			end
		end
	end

	if _CM.OM_medic_1 then
		self.special_unit_spawn_limits.medic = self.special_unit_spawn_limits.medic + 2
	end

	if _CM.OM_dozer_1 then
		self.special_unit_spawn_limits.tank = self.special_unit_spawn_limits.tank + 2
	end

	if _CM.OM_dozer_lmg and difficulty_index <= 6 then
		table.insert(self.unit_categories.FBI_tank.unit_types.america, Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"))
		table.insert(self.unit_categories.FBI_tank.unit_types.russia, Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"))
		table.insert(self.unit_categories.FBI_tank.unit_types.zombie, Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"))
		table.insert(self.unit_categories.FBI_tank.unit_types.murkywater, Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"))
	end

	if _CM.OM_shield_phalanx then
		self.unit_categories.CS_shield.unit_types = self.unit_categories.Phalanx_minion.unit_types
		self.unit_categories.FBI_shield.unit_types = self.unit_categories.Phalanx_minion.unit_types
	end

	if _CM.OM_dozer_2 then
		self.special_unit_spawn_limits.tank = self.special_unit_spawn_limits.tank + 2
	end

	if _CM.OM_medic_2 then
		self.special_unit_spawn_limits.medic = self.special_unit_spawn_limits.medic + 2
	end

	if _CM.OM_dozer_minigun and difficulty_index <= 6 then
		table.insert(self.unit_categories.FBI_tank.unit_types.america, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic"))
		table.insert(self.unit_categories.FBI_tank.unit_types.russia, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic"))
		table.insert(self.unit_categories.FBI_tank.unit_types.zombie, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic"))
		table.insert(self.unit_categories.FBI_tank.unit_types.murkywater, Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"))
	end

	if _CM.OM_dozer_medic and difficulty_index <= 7 then
		table.insert(self.unit_categories.FBI_tank.unit_types.america, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"))
		table.insert(self.unit_categories.FBI_tank.unit_types.russia, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"))
		table.insert(self.unit_categories.FBI_tank.unit_types.zombie, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"))
		table.insert(self.unit_categories.FBI_tank.unit_types.murkywater, Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_medic/ene_murkywater_bulldozer_medic"))
	end
end)