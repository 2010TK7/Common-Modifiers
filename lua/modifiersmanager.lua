function ModifiersManager:modify_value(id, value, ...)
	if CommonModifiers.Checker then
		CommonModifiers:Load()
		local new_value, override = CommonModifiers:modify_value(id, value, ...)
		return (new_value ~= nil or override) and new_value or value
	end

	for _, category in pairs(self._modifiers) do
		for _, modifier in ipairs(category) do
			if modifier.modify_value then
				local new_value, override = modifier:modify_value(id, value, ...)

				if new_value ~= nil or override then
					value = new_value
				end
			end
		end
	end

	return value
end

function ModifiersManager:run_func(func_name, ...)
	if CommonModifiers.Checker then
		if CommonModifiers[func_name] then
			CommonModifiers:Load()
			CommonModifiers[func_name](CommonModifiers, ...)
		end
		return
	end

	for _, category in pairs(self._modifiers) do
		for _, modifier in ipairs(category) do
			if modifier[func_name] then
				modifier[func_name](modifier, ...)
			end
		end
	end
end