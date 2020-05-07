Hooks:Add('LocalizationManagerPostInit', 'CM_LocalizationManagerPostInit', function(loc)
	loc:load_localization_file(CommonModifiers._path .. 'loc/loc.txt', false)
end)

Hooks:Add('MenuManagerInitialize', 'CM_MenuManagerInitialize', function(menu_manager)
	MenuCallbackHandler.CMCheck = function(this, item)
		CommonModifiers.settings[item:name()] = item:value() == 'on'
		CommonModifiers:Save()
	end

	MenuCallbackHandler.CMSave = function(this, item)
		CommonModifiers:Save()
	end

	CommonModifiers:Load()
	MenuHelper:LoadFromJsonFile(CommonModifiers._path .. 'menu/CM_options.txt', CommonModifiers, CommonModifiers.settings)
	MenuHelper:LoadFromJsonFile(CommonModifiers._path .. 'menu/CM_custom.txt', CommonModifiers, CommonModifiers.settings)
	MenuHelper:LoadFromJsonFile(CommonModifiers._path .. 'menu/CM_loud.txt', CommonModifiers, CommonModifiers.settings)
	MenuHelper:LoadFromJsonFile(CommonModifiers._path .. 'menu/CM_stealth.txt', CommonModifiers, CommonModifiers.settings)
end)