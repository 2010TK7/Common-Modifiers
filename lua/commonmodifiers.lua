local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

_G.CommonModifiers = _G.CommonModifiers or {}
CommonModifiers._path = ModPath
CommonModifiers._data_path = SavePath .. 'TCM.txt'
CommonModifiers.settings = CommonModifiers.settings or {
	CM_BlackDozer = false,
	CM_UOheavies = false,

	OM_heavies = false,
	OM_medic_1 = false,
	OM_heavy_sniper = false,
	OM_dozer_1 = false,
	OM_dozer_lmg = false,
	OM_shield_phalanx = false,
	OM_dozer_2 = false,
	OM_medic_2 = false,
	OM_dozer_minigun = false,
	OM_dozer_medic = false,

	OM_pagers_1 = false,
	OM_pagers_2 = false,
	OM_pagers_3 = false,
	OM_pagers_4 = false
}

function CommonModifiers:modify_value(id, value, ...)
	if id == "GroupAIStateBesiege:SpawningUnit" then
		CommonModifiers:Load()
		if CommonModifiers.settings.OM_heavy_sniper and table.contains(CommonModifiers.heavy_units, value)
 and math.random() < 0.05 then
			return Idstring("units/pd2_dlc_drm/characters/ene_zeal_swat_heavy_sniper/ene_zeal_swat_heavy_sniper")
		else
			return value
		end
	end

	return value
end

function CommonModifiers:run_func(func_name, ...)
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

	["units/pd2_dlc_bph/characters/ene_murkywater_light/ene_murkywater_light"] = "units/pd2_dlc_bph/characters/ene_murkywater_heavy_shotgun/ene_murkywater_heavy_shotgun",
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