---@class Instantiate The class which provides a class instantiate function.

Instantiate = {
	---Instantiate class.
	---@param class table Inherited class
	---@param super table|nil Class from which inherited
	---@param ... any Class args
	instantiate = function (class, super, ...)
		local instance = super and super.new(...) or {}
		setmetatable(instance, {__index = class})
		setmetatable(class, {__index = super})
		return instance
	end
}

return Instantiate