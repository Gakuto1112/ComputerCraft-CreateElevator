---@class Install Install wizard base class.

Instantiate = require("instantiate")

Install = {
	new = function ()
		local instance = Instantiate.instantiate({})
		instance.SourseFile = "" --Main file (setup.lua) + config
		instance.SubFiles = {} --Sub file (keeps its name after copying)
		instance.ConfigList = {} --A list of config questions. {name: Config name, desc: Config question text, type: Answer type}
		instance.ConfigData = {}
		return instance
	end,

	redString = function (message)
		local isColor = term.isColor()
		if isColor then
			term.setTextColor(colors.red)
		end
		print(message)
		if isColor then
			term.setTextColor(colors.white)
		end
	end,

	setup = function (self)
		print("Install wizard of \""..self.SourseFile.."\"")
		if fs.exists(shell.resolve(self.SourseFile)) then
			local completion = require("cc.completion")
			local answer = nil
			for _, configQuestion in ipairs(self.ConfigList) do
				print(configQuestion.desc)
				while true do
					local function invalidInput()
						self.redString("Invalid input.")
					end

					write("["..configQuestion.type.."]> ")
					if configQuestion.type == "number" then
						answer = tonumber(read())
						if answer then
							break
						else
							invalidInput()
						end
					elseif configQuestion.type == "integer" then
						answer = tonumber(read())
						if answer and answer % 1 == 0 then
							break
						else
							invalidInput()
						end
					elseif configQuestion.type == "face" then
						answer = read(nil, nil, completion.side)
						if answer == "top" or answer == "front" or answer == "left" or answer == "back" or answer == "right" or answer == "bottom" then
							break
						else
							invalidInput()
						end
					elseif configQuestion.type == "bool" then
						answer = string.lower(read(nil, nil, function (text)
							return completion.choice(text, {"yes", "no"})
						end))
						if answer == "yes" then
							answer = true
							break
						elseif answer == "no" then
							answer = false
							break
						else
							invalidInput()
						end
					end
				end
				table.insert(self.ConfigData, {name = configQuestion.name, type = configQuestion.type, data = answer})
			end
			print("Copying...")
			for _, subFile in ipairs(self.SubFiles) do
				if fs.exists(shell.resolve(subFile)) then
					fs.copy(shell.resolve(subFile), shell.resolve("../"..subFile))
				else
					self.redString("File \""..subFile.."\" does not exist! Skipping...")
				end
			end
			local sourceFile = fs.open(shell.resolve(self.SourseFile), "r")
			local destinationFile = fs.open(shell.resolve("../startup.lua"), "a")
			local isInConfig = false
			while true do
				local line = sourceFile.readLine()
				if line then
					if line == "Config = {" then
						isInConfig = true
						destinationFile.write("Config = {\n")
						for _, configElement in ipairs(self.ConfigData) do
							if configElement.type == "face" then
								destinationFile.write("\t"..configElement.name.." = \""..configElement.data.."\",\n")
							elseif configElement.type == "bool" then
								destinationFile.write("\t"..configElement.name.." = "..(configElement.data and "true" or "false")..",\n")
							else
								destinationFile.write("\t"..configElement.name.." = "..configElement.data..",\n")
							end
						end
						destinationFile.write("}\n")
					elseif line == "}" and isInConfig then
						isInConfig = false
					elseif not isInConfig then
						destinationFile.write(line.."\n")
					end
				else
					break
				end
			end
			sourceFile.close()
			destinationFile.close()
			while true do
				print("Copy complete! Restart now?")
				write("[bool]> ")
				answer = string.lower(read(nil, nil, function (text)
					return completion.choice(text, {"yes", "no"})
				end))
				if answer == "y" or answer == "yes" then
					os.reboot()
				elseif answer == "n" or answer == "no" then
					break
				end
			end
		else
			self.redString("Sourse file does not exist!")
		end
	end
}

return Install