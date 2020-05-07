function ModifiersManager:modify_value(id, value, ...)
	if CommonModifiers.Checker then
		return CommonModifiers:modify_value(id, value, ...)
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
		CommonModifiers:run_func(func_name, ...)
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