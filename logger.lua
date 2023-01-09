---@class Logger The class to print logs.

---@alias Logger.LogType
---| "INFO"
---| "WARN"
---| "ERROR"

Logger = {
	---Returns a string which represents time and day in game.
	---@return string dateString A string which represents time and day in game.
	getDate = function ()
		return os.day().."-"..textutils.formatTime(os.time(), true)
	end,

	---Prints log.
	---@param logType Logger.LogType The type of log.
	---@param color number The color of log characters. Use global "colors" for color name.
	---@param message string A string to print.
	printLog = function (self, logType, color, message)
		write("["..self.getDate().."/")
		term.setTextColor(color)
		write(logType)
		term.setTextColor(colors.white)
		print("]: "..message)
	end,

	---Prints info log.
	---@param message string A string to print.
	info = function (self, message)
		self:printLog("INFO", colors.white, message)
	end,

	---Prints warning log.
	---@param message string A string to print.
	warn = function (self, message)
		self:printLog("WARN", colors.yellow, message)
	end,

	---Prints error log.
	---@param message string A string to print.
	error = function (self, message)
		self:printLog("ERROR", colors.red, message)
	end
}

return Logger