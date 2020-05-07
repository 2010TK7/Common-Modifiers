Hooks:Add('LocalizationManagerPostInit', 'CM_LocalizationManagerPostInit', function(loc)
	loc:load_localization_file(CommonModifiers._path .. 'loc.json', false)
end)

Hooks:Add('MenuManagerInitialize', 'CM_MenuManagerInitialize', function(menu_manager)
	MenuCallbackHandler.CMCheck = function(this, item)
		CommonModifiers.settings[item:name()] = tonumber(item:value())
		CommonModifiers:Save()
	end

	MenuCallbackHandler.CMSave = function(this, item)
		CommonModifiers:Save()
	end

	CommonModifiers:Load()
	if CommonModifiers.settings.pro == 2 then
		MenuHelper:LoadFromJsonFile(CommonModifiers._path .. 'menu/menu.json', CommonModifiers, CommonModifiers.settings)
		MenuHelper:LoadFromJsonFile(CommonModifiers._path .. 'menu/loud.json', CommonModifiers, CommonModifiers.settings)
		MenuHelper:LoadFromJsonFile(CommonModifiers._path .. 'menu/stealth.json', CommonModifiers, CommonModifiers.settings)
	else
		MenuHelper:LoadFromJsonFile(CommonModifiers._path .. 'menu/menu_lite.json', CommonModifiers, CommonModifiers.settings)
		MenuHelper:LoadFromJsonFile(CommonModifiers._path .. 'menu/loud_lite.json', CommonModifiers, CommonModifiers.settings)
		MenuHelper:LoadFromJsonFile(CommonModifiers._path .. 'menu/stealth_lite.json', CommonModifiers, CommonModifiers.settings)
	end
end)