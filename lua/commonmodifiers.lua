local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

_G.CommonModifiers = _G.CommonModifiers or {}
CommonModifiers._path = ModPath
CommonModifiers._data_path = SavePath .. 'TCM.txt'
CommonModifiers.settings = CommonModifiers.settings or {
	CM_BlackDozer = false,
	CM_UOheavies = false,
	CM_civ_0 = false,

	OM_shield_reflect = nil,
	OM_cloaker_smoke = nil,
	OM_medic_heal_1 = nil,
	OM_no_hurt = false,
	OM_taser_overcharge = nil,
	OM_heavies = false,
	OM_medic_1 = false,
	OM_heavy_sniper = false,
	OM_dozer_rage = false,
	OM_cloaker_tear_gas = false,
	OM_dozer_1 = false,
	OM_medic_heal_2 = nil,
	OM_dozer_lmg = false,
	OM_medic_adrenaline = false,
	OM_shield_phalanx = false,
	OM_dozer_2 = false,
	OM_medic_deathwish = false,
	OM_dozer_minigun = false,
	OM_medic_2 = false,
	OM_dozer_immunity = nil,
	OM_dozer_medic = false,
	OM_assault_extender = false,
	OM_cloaker_arrest = nil,
	OM_medic_rage = false,

	OM_pagers_1 = false,
	OM_civs_1 = false,
	OM_conceal_1 = nil,
	OM_civs_2 = false,
	OM_pagers_2 = false,
	OM_conceal_2 = nil,
	OM_pagers_3 = false,
	OM_civs_3 = false,
	OM_pagers_4 = false
}

local _CM = CommonModifiers.settings

function CommonModifiers:modify_value(id, value, ...)
	if id == "PlayerMovement:OnSpooked" then
		if _CM.OM_cloaker_arrest then
			return "arrested"
		end
	elseif id == "CopDamage:DamageExplosion" then
		local unit_tweak = ...
		if _CM.OM_dozer_immunity and unit_tweak == "tank" then
			return 0
		end
	elseif id == "MedicDamage:CooldownTime" then
		if _CM.OM_medic_heal_1 or _CM.OM_medic_heal_2 then
			return value * self:get_cooldown_multiplier()
		end
	elseif id == "GroupAIStateBesiege:SpawningUnit" then
		if _CM.OM_heavy_sniper and table.contains(CommonModifiers.heavy_units, value) and math.random() < (5) * 0.01 then
			return Idstring("units/pd2_dlc_drm/characters/ene_zeal_swat_heavy_sniper/ene_zeal_swat_heavy_sniper")
		end
	elseif id == "BlackMarketManager:GetConcealment" then
		if _CM.OM_conceal_1 or _CM.OM_conceal_2 then
			return value + (_CM.OM_conceal_1 and _CM.OM_conceal_2 and 6 or 3)
		end
	elseif id == "CopMovement:HurtType" then
		if _CM.OM_no_hurt and table.contains({"expl_hurt", "knock_down", "stagger", "heavy_hurt", "hurt", "light_hurt"}, value) then
			return nil, true
		end
	elseif id == "PlayerStandart:_start_action_intimidate" then
		local unit = ...
		local unit_tweak = unit:base()._tweak_table
		if _CM.OM_shield_phalnx and unit_tweak == "phalanx_minion" then
			if unit:base().is_phalanx then
				return
			else
				return "f31x_any"
			end
		end
	elseif id == "FragGrenade:ShouldReflect" then
		local hit_unit, unit = ...
		local is_shield = hit_unit:in_slot(8)
		if _CM.OM_shield_reflect and is_shield then
			return true
		end
	elseif id == "PlayerTased:TasedTime" then
		if _CM.OM_taser_overcharge then
			value = value / ((50) * 0.01 + 1)
		end
	elseif _CM.OM_assault_extender then
		self._sustain_start_time = self._sustain_start_time or 0
		self._base_duration = self._base_duration or 0
		self._hostage_time = self._hostage_time or 0
		self._hostage_count = self._hostage_count or 0
		self._hostage_average_count = self._hostage_average_count or 0
		self._hostage_last_update = self._hostage_last_update or 0
		if id == "GroupAIStateBesiege:SustainEndTime" then
			self:_update_hostage_time()
			local now = TimerManager:game():time()
			local extension = (50) * 0.01
			local deduction = (4) * 0.01 * self._hostage_average_count
			local value = value + self._base_duration * (extension - deduction)
			return value
		elseif id == "GroupAIStateBesiege:SustainSpawnAllowance" then
			self:_update_hostage_time()
			local now = TimerManager:game():time()
			local base_pool = ...
			local extension = (50) * 0.01
			local deduction = (4) * 0.01 * self._hostage_average_count
			local value = value + math.floor(base_pool * (extension - deduction))
			return value
		end
	end
	return value
end

function CommonModifiers:_update_hostage_time()
	if not _CM.OM_assault_extender then
		return
	end

	local now = TimerManager:game():time()
	local diff = now - self._hostage_last_update
	self._hostage_time = self._hostage_time + diff * self._hostage_count
	self._hostage_average_count = self._hostage_time / (now - self._sustain_start_time)
	self._hostage_last_update = now
end

function CommonModifiers:_update_hostage_count()
	if not _CM.OM_assault_extender then
		return
	end

	local num_hostages = managers.groupai:state():hostage_count()
	local num_minions = managers.groupai:state():get_amount_enemies_converted_to_criminals()
	self._hostage_count = math.min(num_hostages + num_minions, (8))
end

function CommonModifiers:OnHostageCountChanged()
	if not _CM.OM_assault_extender then
		return
	end

	self:_update_hostage_time()
	self:_update_hostage_count()
end

function CommonModifiers:OnMinionAdded()
	if not _CM.OM_assault_extender then
		return
	end

	self:_update_hostage_time()
	self:_update_hostage_count()
end

function CommonModifiers:OnMinionRemoved()
	if not _CM.OM_assault_extender then
		return
	end

	self:_update_hostage_time()
	self:_update_hostage_count()
end

function CommonModifiers:OnEnterSustainPhase(duration)
	if not _CM.OM_assault_extender then
		return
	end

	local now = TimerManager:game():time()
	self._sustain_start_time = now
	self._base_duration = duration
	self._hostage_time = 0
	self._hostage_last_update = now
end

function CommonModifiers:OnCivilianKilled()
	self._body_count = (self._body_count or 0) + 1
	if (_CM.CM_civ_0 or _CM.OM_civs_1 or _CM.OM_civs_2 or _CM.OM_civs_3) and (_CM.CM_civ_0 and 0 or _CM.OM_civs_3 and 4 or _CM.OM_civs_2 and 7 or _CM.OM_civs_1 and 10) < self._body_count and not self._alarmed then
		managers.groupai:state():on_police_called("civ_too_many_killed")
		self._alarmed = true
	end
end

function CommonModifiers:OnPlayerCloakerKicked(cloaker_unit)
	local effect_func = MutatorCloakerEffect["effect_" .. tostring("smoke")]
	if _CM.OM_cloaker_smoke and effect_func then
		effect_func(self, cloaker_unit)
	end
end

function CommonModifiers:OnEnemyDied(unit, damage_info)
	if Network:is_client() then
		return
	end

	if _CM.OM_cloaker_tear_gas and unit:base()._tweak_table == "spooc" then
		local grenade = World:spawn_unit(Idstring("units/pd2_dlc_drm/weapons/smoke_grenade_tear_gas/smoke_grenade_tear_gas"), unit:position(), unit:rotation())
		grenade:base():set_properties({
			radius = (4) * 0.5 * 100,
			damage = (30) * 0.1,
			duration = (10)
		})
		grenade:base():detonate()
	end

	if _CM.OM_medic_deathwish and unit:base():has_tag("medic") then
		local enemies = World:find_units_quick(unit, "sphere", unit:position(), tweak_data.medic.radius, managers.slot:get_mask("enemies"))
		for _, enemy in ipairs(enemies) do
			if unit:character_damage():heal_unit(enemy, true) then
				enemy:movement():action_request({
					body_part = 3,
					type = "healed",
					client_interrupt = Network:is_client()
				})
			end
		end
	end

	if _CM.OM_medic_rage then
		local team_id = unit:brain()._logic_data.team and unit:brain()._logic_data.team.id or "law1"
		if team_id ~= "law1" then
			return
		end
		local enemies = World:find_units_quick(unit, "sphere", unit:position(), tweak_data.medic.radius, managers.slot:get_mask("enemies"))
		for _, enemy in ipairs(enemies) do
			if enemy:base():has_tag("medic") then
				enemy:base():add_buff("base_damage", (20) * 0.01)
			end
		end
	end
end

function CommonModifiers:OnTankVisorShatter(unit, damage_info)
	if _CM.OM_dozer_rage then
		unit:base():add_buff("base_damage", (100) * 0.01)
	end
end

function CommonModifiers:get_cooldown_multiplier()
	if _CM.OM_medic_heal_1 or _CM.OM_medic_heal_2 then
		return 1 - (_CM.OM_medic_heal_1 and _CM.OM_medic_heal_2 and 40 or 20) / 100
	end
end

function CommonModifiers:OnEnemyHealed(medic, target)
	if _CM.OM_medic_adrenaline then
		target:base():add_buff("base_damage", (100) * 0.01)
	end
end

CommonModifiers.Checker = Global.game_settings and Global.game_settings.gamemode ~= "crime_spree" and Global.game_settings.gamemode ~= "skirmish"

function CommonModifiers:Save()
	local file = io.open(self._data_path, 'w+')
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function CommonModifiers:Load()
	local file = io.open(self._data_path, 'r')
	if file then
		for k, v in pairs(json.decode(file:read('*all')) or {}) do
			self.settings[k] = v
		end
		file:close()
	end
end

CommonModifiers.UO_heavies = {
	["units/payday2/characters/ene_swat_1/ene_swat_1"] = "units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1",
	["units/payday2/characters/ene_swat_2/ene_swat_2"] = "units/payday2/characters/ene_swat_heavy_r870/ene_swat_heavy_r870",
	["units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"] = "units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1",
	["units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"] = "units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870",
	["units/payday2/characters/ene_city_swat_1/ene_city_swat_1"] = "units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36",
	["units/payday2/characters/ene_city_swat_r870/ene_city_swat_r870"] = "units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870",
	["units/payday2/characters/ene_city_swat_3/ene_city_swat_3"] = "units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36",
	["units/payday2/characters/ene_city_swat_2/ene_city_swat_2"] = "units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870",

	["units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat"] = "units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy",

	["units/pd2_dlc_mad/characters/ene_akan_cs_swat_ak47_ass/ene_akan_cs_swat_ak47_ass"] = "units/pd2_dlc_mad/characters/ene_akan_cs_heavy_ak47_ass/ene_akan_cs_heavy_ak47_ass",
	["units/pd2_dlc_mad/characters/ene_akan_cs_swat_r870/ene_akan_cs_swat_r870"] = "units/pd2_dlc_mad/characters/ene_akan_cs_heavy_r870/ene_akan_cs_heavy_r870",
	["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"] = "units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36",
	["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870"] = "units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870/ene_akan_fbi_heavy_r870",
	["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass"] = "units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36",
	["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_r870/ene_akan_fbi_swat_dw_r870"] = "units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870/ene_akan_fbi_heavy_r870",

	["units/pd2_dlc_hvh/characters/ene_swat_hvh_1/ene_swat_hvh_1"] = "units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_1/ene_swat_heavy_hvh_1",
	["units/pd2_dlc_hvh/characters/ene_swat_hvh_2/ene_swat_hvh_2"] = "units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_r870/ene_swat_heavy_hvh_r870",
	["units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"] = "units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1",
	["units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2"] = "units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870",

	["units/pd2_dlc_bph/characters/ene_murkywater_light/ene_murkywater_light"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy/ene_murkywater_heavy",
	["units/pd2_dlc_bph/characters/ene_murkywater_light_r870/ene_murkywater_light_r870"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_shotgun/ene_murkywater_heavy_shotgun",
	["units/pd2_dlc_bph/characters/ene_murkywater_light_fbi/ene_murkywater_light_fbi"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_g36/ene_murkywater_heavy_g36",
	["units/pd2_dlc_bph/characters/ene_murkywater_light_fbi_r870/ene_murkywater_light_fbi_r870"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_shotgun/ene_murkywater_heavy_shotgun",
	["units/pd2_dlc_bph/characters/ene_murkywater_light_city/ene_murkywater_light_city"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_g36/ene_murkywater_heavy_g36",
	["units/pd2_dlc_bph/characters/ene_murkywater_light_city_r870/ene_murkywater_light_city_r870"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_shotgun/ene_murkywater_heavy_shotgun"
}

CommonModifiers.unit_swaps = {
	["units/payday2/characters/ene_swat_1/ene_swat_1"] = "units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870",
	["units/payday2/characters/ene_swat_2/ene_swat_2"] = "units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1",
	["units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"] = "units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870",
	["units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"] = "units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36",
	["units/payday2/characters/ene_city_swat_1/ene_city_swat_1"] = "units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870",
	["units/payday2/characters/ene_city_swat_r870/ene_city_swat_r870"] = "units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36",
	["units/payday2/characters/ene_city_swat_3/ene_city_swat_3"] = "units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870",
	["units/payday2/characters/ene_city_swat_2/ene_city_swat_2"] = "units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36",

	["units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat"] = "units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy",

	["units/pd2_dlc_mad/characters/ene_akan_cs_swat_ak47_ass/ene_akan_cs_swat_ak47_ass"] = "units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870/ene_akan_fbi_heavy_r870",
	["units/pd2_dlc_mad/characters/ene_akan_cs_swat_r870/ene_akan_cs_swat_r870"] = "units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36",
	["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"] = "units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870/ene_akan_fbi_heavy_r870",
	["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870"] = "units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36",
	["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass"] = "units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870/ene_akan_fbi_heavy_r870",
	["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_r870/ene_akan_fbi_swat_dw_r870"] = "units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36",

	["units/pd2_dlc_hvh/characters/ene_swat_hvh_1/ene_swat_hvh_1"] = "units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870",
	["units/pd2_dlc_hvh/characters/ene_swat_hvh_2/ene_swat_hvh_2"] = "units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1",
	["units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"] = "units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870",
	["units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2"] = "units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1",

	["units/pd2_dlc_bph/characters/ene_murkywater_light/ene_murkywater_light"] = Global.game_settings and Global.game_settings.difficulty == "sm_wish" and "units/pd2_dlc_bph/characters/ene_murkywater_heavy/ene_murkywater_heavy" or "units/pd2_dlc_bph/characters/ene_murkywater_heavy_shotgun/ene_murkywater_heavy_shotgun",
	["units/pd2_dlc_bph/characters/ene_murkywater_light_r870/ene_murkywater_light_r870"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_g36/ene_murkywater_heavy_g36",
	["units/pd2_dlc_bph/characters/ene_murkywater_light_fbi/ene_murkywater_light_fbi"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_shotgun/ene_murkywater_heavy_shotgun",
	["units/pd2_dlc_bph/characters/ene_murkywater_light_fbi_r870/ene_murkywater_light_fbi_r870"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_g36/ene_murkywater_heavy_g36",
	["units/pd2_dlc_bph/characters/ene_murkywater_light_city/ene_murkywater_light_city"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_shotgun/ene_murkywater_heavy_shotgun",
	["units/pd2_dlc_bph/characters/ene_murkywater_light_city_r870/ene_murkywater_light_city_r870"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_g36/ene_murkywater_heavy_g36"
}

CommonModifiers.heavy_units = {
	Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1"),
	Idstring("units/payday2/characters/ene_swat_heavy_r870/ene_swat_heavy_r870"),
	Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"),
	Idstring("units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870"),
	Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36"),
	Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870"),

	Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"),

	Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_heavy_ak47_ass/ene_akan_cs_heavy_ak47_ass"),
	Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_heavy_r870/ene_akan_cs_heavy_r870"),
	Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36"),
	Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870/ene_akan_fbi_heavy_r870"),

	Idstring("units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_1/ene_swat_heavy_hvh_1"),
	Idstring("units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_r870/ene_swat_heavy_hvh_r870"),
	Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1"),
	Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870"),

	Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy/ene_murkywater_heavy"),
	Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy_shotgun/ene_murkywater_heavy_shotgun"),
	Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy_g36/ene_murkywater_heavy_g36")
}