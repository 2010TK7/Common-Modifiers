local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

_G.CommonModifiers = _G.CommonModifiers or {}
CommonModifiers._path = ModPath
CommonModifiers._data_path = SavePath .. 'Tmod_TCM.txt'
CommonModifiers.settings = CommonModifiers.settings or {
	shield_reflect = 2,
	cloaker_smoke = 2,
	medic_heal_2 = 3,
	no_hurt = 2,
	taser_overcharge = 2,
	heavies = 2,
	medic_2 = 3,
	heavy_sniper = 2,
	dozer_rage = 2,
	cloaker_tear_gas = 3,
	dozer_2 = 3,
	dozer_lmg = 2,
	medic_adrenaline = 2,
	shield_phalanx = 2,
	medic_deathwish = 2,
	dozer_minigun = 2,
	dozer_immunity = 2,
	dozer_medic = 2,
	assault_extender = 2,
	cloaker_arrest = 2,
	medic_rage = 2,

	pagers_4 = 5,
	civs_3 = 4,
	conceal_2 = 3,

	pro = 1,

	BlackDozer = 1,
	ShadowSpooc = 1,
	DiffIndex = 1,
	ReCaptain = 1
}

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

local _CM = CommonModifiers.settings

function CommonModifiers:Difficulty(difficulty_index)
	CommonModifiers:Load()
	if _CM.DiffIndex == 3 then
		return 8
	elseif _CM.DiffIndex == 2 and difficulty_index <= 7 then
		return 7
	else
		return difficulty_index
	end
end

function CommonModifiers:modify_value(id, value, ...)
	CommonModifiers:Load()
	if _CM.assault_extender == 1 and (id == "GroupAIStateBesiege:SustainEndTime" or id == "GroupAIStateBesiege:SustainSpawnAllowance") then
		return CommonModifiers:AssaultExtender(id, value, ...)
	end--AssaultExtender
	if _CM.cloaker_arrest == 1 and id == "PlayerMovement:OnSpooked" then
		return "arrested"
	end--CloakerArrest
	if _CM.dozer_immunity == 1 and id == "CopDamage:DamageExplosion" then
		--useless in crime spree =(
		local unit_tweak = ...
		if unit_tweak == "tank" or unit_tweak == "tank_hw" or unit_tweak == "tank_medic" or unit_tweak == "tank_mini" then
			return 0
		end
	end--ExplosionImmunity
	if (_CM.medic_heal_2 == 1 or _CM.medic_heal_2 == 2 or _CM.medic_heal_2 == 4) and id == "MedicDamage:CooldownTime" then
		return value * (_CM.medic_heal_2 == 4 and 0 or _CM.medic_heal_2 * 0.2 + 0.4)
	end--HealSpeed
	if _CM.heavy_sniper == 1 and id == "GroupAIStateBesiege:SpawningUnit" then
		if table.contains(CommonModifiers.heavy_units, value) and math.random() < (5) * 0.01 then
			return Idstring("units/pd2_dlc_drm/characters/ene_zeal_swat_heavy_sniper/ene_zeal_swat_heavy_sniper")
		end
	end--HeavySniper
	if (_CM.conceal_2 >= 1 and _CM.conceal_2 <= 5 and _CM.conceal_2 ~= 3) and id == "BlackMarketManager:GetConcealment" then
		return value + (_CM.conceal_2 <= 2 and (9 - 3 * _CM.conceal_2) or _CM.conceal_2 == 4 and 18 or 28)
	end--LessConcealment
	if (_CM.no_hurt == 1 or _CM.no_hurt == 3) and id == "CopMovement:HurtType" then
		if _CM.no_hurt == 3 or table.contains({"expl_hurt", "knock_down", "stagger", "heavy_hurt", "hurt", "light_hurt"}, value) then
			return nil
		end
	end--NoHurtAnims
	if _CM.shield_phalanx == 1 and id == "PlayerStandart:_start_action_intimidate" then
		local unit = ...
		local unit_tweak = unit:base()._tweak_table
		if unit_tweak == "phalanx_minion" and not unit:base().is_phalanx then
			return "f31x_any"
		end
	end--ShieldPhalanx
	if _CM.shield_reflect and id == "FragGrenade:ShouldReflect" then
		local hit_unit, unit = ...
		local is_shield = hit_unit:in_slot(8)
		if is_shield then
			return true
		end
	end--ShieldReflect
	if (_CM.taser_overcharge == 1 or _CM.taser_overcharge == 3) and id == "PlayerTased:TasedTime" then
		return _CM.taser_overcharge == 1 and (value / 1.5) or 0
	end--TaserOvercharge
	return value
end--modify_value

function CommonModifiers:run_func(func_name, ...)
	CommonModifiers:Load()
	if _CM.assault_extender == 1 and (func_name == "OnHostageCountChanged" or func_name == "OnMinionAdded" or func_name == "OnMinionRemoved" or func_name == "OnEnterSustainPhase") then
		if func_name == "OnEnterSustainPhase" then
			CommonModifiers:OnEnterSustainPhase(...)
		else
			self:_update_hostage_time()
			self:_update_hostage_count()
		end
	end--AssaultExtender
	if (_CM.civs_3 >= 1 and _CM.civs_3 <= 5 and _CM.civs_3 ~= 4) and func_name == "OnCivilianKilled" then
		CommonModifiers:OnCivilianKilled()
	end--CivilianAlarm
	if _CM.cloaker_smoke == 1 and func_name == "OnPlayerCloakerKicked" then
		CommonModifiers:OnPlayerCloakerKicked(...)
	end--CloakerKick
	if (_CM.cloaker_tear_gas == 1 or _CM.medic_deathwish == 1 or _CM.medic_rage == 1) and func_name == "OnEnemyDied" then
		CommonModifiers:OnEnemyDied(...)
	end--CloakerTearGas, MedicDeathwish, MedicRage
	if _CM.dozer_rage == 1 and func_name == "OnTankVisorShatter" then
		CommonModifiers:OnTankVisorShatter(...)
	end--DozerRage
	if _CM.medic_adrenaline == 1 and func_name == "OnEnemyHealed" then
		CommonModifiers:OnEnemyHealed(...)
	end--MedicAdrenaline
end--run_func

--tweak_data.group_ai
function CommonModifiers:special_unit_spawn_limits(limits, difficulty_index)
	CommonModifiers:Load()
	if difficulty_index ~= CommonModifiers:Difficulty(difficulty_index) then
		limits.shield = 4
		limits.medic = 3
		limits.taser = 3
		limits.tank = _CM.DiffIndex == 2 and 2 or 3
		limits.spooc = 2
	end--(DiffIndex)
	if _CM.dozer_2 == 1 or _CM.dozer_2 == 2 then
		limits.tank = limits.tank + (6 - 2 * _CM.dozer_2)
	end--MoreDozers
	if _CM.medic_2 == 1 or _CM.medic_2 == 2 then
		limits.medic = limits.medic + (6 - 2 * _CM.medic_2)
	end--MoreMedics
end

function CommonModifiers:unit_categories(categories, difficulty_index)
	CommonModifiers:Load()
	if _CM.dozer_medic == 1 and difficulty_index <= 7 then
		table.insert(categories.FBI_tank.unit_types.america, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"))
		table.insert(categories.FBI_tank.unit_types.russia, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"))
		table.insert(categories.FBI_tank.unit_types.zombie, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"))
		table.insert(categories.FBI_tank.unit_types.murkywater, Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_medic/ene_murkywater_bulldozer_medic"))
		table.insert(categories.FBI_tank.unit_types.federales, Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_medic_policia_federale/ene_swat_dozer_medic_policia_federale"))
	end--DozerMedic
	if _CM.dozer_minigun == 1 and difficulty_index <= 6 then
		table.insert(categories.FBI_tank.unit_types.america, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic"))
		table.insert(categories.FBI_tank.unit_types.russia, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic"))
		table.insert(categories.FBI_tank.unit_types.zombie, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic"))
		table.insert(categories.FBI_tank.unit_types.murkywater, Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"))
		table.insert(categories.FBI_tank.unit_types.federales, Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_minigun/ene_swat_dozer_policia_federale_minigun"))
	end--DozerMinigun
	if _CM.heavies == 1 then
		for group, unit_group in pairs(categories) do
			if group == "FBI_swat_M4" or group == "FBI_swat_R870" then
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
	elseif _CM.heavies == 3 then
		categories.CS_swat_MP5 = categories.CS_heavy_M4
		categories.CS_swat_R870 = categories.CS_heavy_R870
		categories.FBI_swat_M4 = categories.FBI_heavy_G36
		categories.FBI_swat_R870 = categories.FBI_heavy_R870
	end--Heavies
	if _CM.shield_phalanx == 1 then
		categories.CS_shield.unit_types = categories.Phalanx_minion.unit_types
		categories.FBI_shield.unit_types = categories.Phalanx_minion.unit_types
	end--ShieldPhalanx
	if _CM.dozer_lmg == 1 and difficulty_index <= 6 then
		table.insert(categories.FBI_tank.unit_types.america, Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"))
		table.insert(categories.FBI_tank.unit_types.russia, Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"))
		table.insert(categories.FBI_tank.unit_types.zombie, Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"))
		table.insert(categories.FBI_tank.unit_types.murkywater, Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"))
		table.insert(categories.FBI_tank.unit_types.federales, Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_m249/ene_swat_dozer_policia_federale_m249"))
	end--Skulldozers
	if _CM.BlackDozer == 2 and difficulty_index <= 4 then
		table.insert(categories.FBI_tank.unit_types.america, Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"))
		table.insert(categories.FBI_tank.unit_types.russia, Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"))
		table.insert(categories.FBI_tank.unit_types.zombie, Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"))
		table.insert(categories.FBI_tank.unit_types.murkywater, Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"))
		table.insert(categories.FBI_tank.unit_types.federales, Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870"))
	end--(BlackDozer)
	if _CM.ShadowSpooc == 2 and PackageManager:loaded("packages/dlcs/vit/job_vit") then
		categories.spooc.unit_types = {
			america = {
				Idstring("units/pd2_dlc_uno/characters/ene_shadow_cloaker_1/ene_shadow_cloaker_1"),
				Idstring("units/pd2_dlc_uno/characters/ene_shadow_cloaker_2/ene_shadow_cloaker_2")
			},
			russia = {
				Idstring("units/pd2_dlc_uno/characters/ene_shadow_cloaker_1/ene_shadow_cloaker_1"),
				Idstring("units/pd2_dlc_uno/characters/ene_shadow_cloaker_2/ene_shadow_cloaker_2")
			},
			zombie = {
				Idstring("units/pd2_dlc_uno/characters/ene_shadow_cloaker_1/ene_shadow_cloaker_1"),
				Idstring("units/pd2_dlc_uno/characters/ene_shadow_cloaker_2/ene_shadow_cloaker_2")
			},
			murkywater = {
				Idstring("units/pd2_dlc_uno/characters/ene_shadow_cloaker_1/ene_shadow_cloaker_1"),
				Idstring("units/pd2_dlc_uno/characters/ene_shadow_cloaker_2/ene_shadow_cloaker_2")
			},
			federales = {
				Idstring("units/pd2_dlc_uno/characters/ene_shadow_cloaker_1/ene_shadow_cloaker_1"),
				Idstring("units/pd2_dlc_uno/characters/ene_shadow_cloaker_2/ene_shadow_cloaker_2")
			}
		}
	end--(ShadowSpooc)
end--tweak_data.group_ai

--AssaultExtender
function CommonModifiers:_update_hostage_time()
	local now = TimerManager:game():time()
	local diff = now - (self._hostage_last_update or 0)
	self._hostage_time = (self._hostage_time or 0) + diff * (self._hostage_count or 0)
	self._hostage_average_count = self._hostage_time / (now - (self._sustain_start_time or 0))
	self._hostage_last_update = now
end

function CommonModifiers:_update_hostage_count()
	local num_hostages = managers.groupai:state():hostage_count()
	local num_minions = managers.groupai:state():get_amount_enemies_converted_to_criminals()
	self._hostage_count = math.min(num_hostages + num_minions, (8))
end

function CommonModifiers:OnEnterSustainPhase(duration)
	local now = TimerManager:game():time()
	self._sustain_start_time = now
	self._base_duration = duration
	self._hostage_time = 0
	self._hostage_last_update = now
end

function CommonModifiers:AssaultExtender(id, value, ...)
	self:_update_hostage_time()
	local now = TimerManager:game():time()
	local extension = (50) * 0.01
	local deduction = (4) * 0.01 * self._hostage_average_count
	if id == "GroupAIStateBesiege:SustainEndTime" then
		local value = value + (self._base_duration or 0) * (extension - deduction)
	elseif id == "GroupAIStateBesiege:SustainSpawnAllowance" then
		local base_pool = ...
		local value = value + math.floor(base_pool * (extension - deduction))
	end
	return value
end--AssaultExtender

--CivilianAlarm
function CommonModifiers:OnCivilianKilled()
	self._body_count = (self._body_count or 0) + 1
	if (_CM.civs_3 == 5 and 0 or _CM.civs_3 * 3 + 1) < self._body_count and not self._alarmed then
		managers.groupai:state():on_police_called("civ_too_many_killed")
		self._alarmed = true
	end
end--CivilianAlarm

--CloakerKick
function CommonModifiers:OnPlayerCloakerKicked(cloaker_unit)
	local effect_func = MutatorCloakerEffect.effect_smoke
	if effect_func then
		effect_func(self, cloaker_unit)
	end
end--CloakerKick

--CloakerTearGas, MedicDeathwish, MedicRage
function CommonModifiers:OnEnemyDied(unit, damage_info)
	if Network:is_client() then
		return
	end

	if (_CM.cloaker_tear_gas == 1 or _CM.cloaker_tear_gas == 2) and (unit:base()._tweak_table == "spooc" or unit:base()._tweak_table == "shadow_spooc") then
		local grenade = World:spawn_unit(Idstring("units/pd2_dlc_drm/weapons/smoke_grenade_tear_gas/smoke_grenade_tear_gas"), unit:position(), unit:rotation())
		grenade:base():set_properties({
			radius = (4) * 0.5 * 100,
			damage = (_CM.cloaker_tear_gas == 1 and 30 or 10) * 0.1,
			duration = _CM.cloaker_tear_gas == 1 and 10 or 5
		})
		grenade:base():detonate()
	end--CloakerTearGas

	if _CM.medic_deathwish == 1 and unit:base():has_tag("medic") then
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
	end--MedicDeathwish

	if _CM.medic_rage == 1 then
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
	end--MedicRage
end--CloakerTearGas, MedicDeathwish, MedicRage

--DozerRage
function CommonModifiers:OnTankVisorShatter(unit, damage_info)
	unit:base():add_buff("base_damage", (100) * 0.01)
end--DozerRage

--Heavies
CommonModifiers.unit_swaps = {
	["units/payday2/characters/ene_swat_1/ene_swat_1"] = "units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870",
	["units/payday2/characters/ene_swat_2/ene_swat_2"] = "units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1",
	["units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"] = "units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870",
	["units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"] = "units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36",
	["units/payday2/characters/ene_city_swat_1/ene_city_swat_1"] = "units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870",
	["units/payday2/characters/ene_city_swat_r870/ene_city_swat_r870"] = "units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1",
	["units/payday2/characters/ene_city_swat_3/ene_city_swat_3"] = "units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870",
	["units/payday2/characters/ene_city_swat_2/ene_city_swat_2"] = "units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1",

	["units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat"] = "units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870",

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

	["units/pd2_dlc_bph/characters/ene_murkywater_light/ene_murkywater_light"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_shotgun/ene_murkywater_heavy_shotgun",
	["units/pd2_dlc_bph/characters/ene_murkywater_light_r870/ene_murkywater_light_r870"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_g36/ene_murkywater_heavy_g36",
	["units/pd2_dlc_bph/characters/ene_murkywater_light_fbi/ene_murkywater_light_fbi"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_shotgun/ene_murkywater_heavy_shotgun",
	["units/pd2_dlc_bph/characters/ene_murkywater_light_fbi_r870/ene_murkywater_light_fbi_r870"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_g36/ene_murkywater_heavy_g36",
	["units/pd2_dlc_bph/characters/ene_murkywater_light_city/ene_murkywater_light_city"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_shotgun/ene_murkywater_heavy_shotgun",
	["units/pd2_dlc_bph/characters/ene_murkywater_light_city_r870/ene_murkywater_light_city_r870"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_g36/ene_murkywater_heavy_g36",

	["units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale"] = "units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_r870/ene_swat_heavy_policia_federale_r870",
	["units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870/ene_swat_policia_federale_r870"] = "units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale/ene_swat_heavy_policia_federale",
	["units/pd2_dlc_bex/characters/ene_swat_policia_federale_city/ene_swat_policia_federale_city"] = "units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870/ene_swat_heavy_policia_federale_fbi_r870",
	["units/pd2_dlc_bex/characters/ene_swat_policia_federale_city_r870/ene_swat_policia_federale_city_r870"] = "units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_g36/ene_swat_heavy_policia_federale_fbi_g36",
	["units/pd2_dlc_bex/characters/ene_swat_policia_federale_city_fbi/ene_swat_policia_federale_city_fbi"] = "units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870/ene_swat_heavy_policia_federale_fbi_r870",
	["units/pd2_dlc_bex/characters/ene_swat_policia_federale_city_fbi_r870/ene_swat_policia_federale_city_fbi_r870"] = "units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi",
	["units/pd2_dlc_bex/characters/ene_swat_policia_federale_fbi/ene_swat_policia_federale_fbi"] = "units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870/ene_swat_heavy_policia_federale_fbi_r870"
}--Heavies

--HeavySniper
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
	Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy_g36/ene_murkywater_heavy_g36"),

	Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale/ene_swat_heavy_policia_federale"),
	Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_r870/ene_swat_heavy_policia_federale_r870"),
	Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_g36/ene_swat_heavy_policia_federale_g36"),
	Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi"),
	Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870/ene_swat_heavy_policia_federale_fbi_r870"),
	Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_g36/ene_swat_heavy_policia_federale_fbi_g36")
}--HeavySniper

--LessPagers
function CommonModifiers:LessPagers(pager)
	CommonModifiers:Load()
	if _CM.pagers_4 >= 1 and _CM.pagers_4 <= 4 then
		pager[_CM.pagers_4] = 0
	end
end--LessPagers

--MedicAdrenaline
function CommonModifiers:OnEnemyHealed(medic, target)
	target:base():add_buff("base_damage", (100) * 0.01)
end--MedicAdrenaline

--(ReCaptain)
function CommonModifiers:ReCaptain(winter)
	CommonModifiers:Load()
	if _CM.ReCaptain == 2 then
		winter.respawn_delay = 120
	end
end--(ReCaptain)