---@alias ProtocolType
---| "EV_DATA_REQ"
---| "EV_DATA_RES"
---| "EV_CALL"
---| "EV_DIRECTION"
---| "EV_FLOOR"

--Program configurations
Config = {
	clutchFace = "left", --The face to control the clutch with redstone.
	gearShiftFace = "right", --The face to control the gear shift with redstone.
	minFloor = 1, --The higheast floor
	maxFloor = 11, --The lowest floor
	timeBetweenFloors = 0.4 --Time to move 1 floor (seconds).
}

Logger = require("logger")
CurrentFloor = 1
ElevatorDirection = 0

---Gets EV data.
---@return table EVData EV data.
function getEVData()
	return {currentFloor = CurrentFloor, direction = ElevatorDirection, minFloor = Config.minFloor, maxFloor = Config.maxFloor}
end

---Processing while the elevator is running.
---@param targetFloor number The floor to go.
function elevatorMove(targetFloor)
	--Parallel functions
	local function elevatorTiming()
		while CurrentFloor ~= targetFloor do
			sleep(Config.timeBetweenFloors)
			CurrentFloor = CurrentFloor + ElevatorDirection
			broadcast({floor = CurrentFloor, isArrived = (CurrentFloor == targetFloor)}, "EV_FLOOR")
		end
		Logger:info("Arried at floor "..CurrentFloor..".")
		ElevatorDirection = 0
		redstone.setOutput(Config.clutchFace, false)
		redstone.setOutput(Config.gearShiftFace, false)

		--Save current floor.
		local file = fs.open(FilePath, "w")
		file.write(CurrentFloor)
		file.close()
	end

	local function rednetStandby()
		while true do
			local event, sender, message, protocol = os.pullEvent("rednet_message")
			if protocol == "EV_DATA_REQ" then
				--Request to send EV data to the target floor computer.
				Logger:info("Sending EV data to #"..sender..".")
				rednet.send(sender, getEVData(), "EV_DATA_RES")
			end
		end
	end

	parallel.waitForAny(elevatorTiming, rednetStandby)
end

---Broadcasts to floor computers.
---@param message any The data to send.
---@param protocol ProtocolType The protocol of the sending message.
function broadcast(message, protocol)
	for _, floorComputer in ipairs({rednet.lookup("EV_SYSTEM_FLOOR")}) do
		rednet.send(floorComputer, message, protocol)
	end
end

--Read elevator position data.
FilePath = "./elevator_position.txt"
if fs.exists(FilePath) then
	local file = fs.open(FilePath, "r")
	local data = file.readAll()
	if data then
		local floor = tonumber(data)
		if floor then
			CurrentFloor = floor
		else
			Logger:warn("Cannot read current floor. Use default value (1).")
		end
		file.close()
	else
		Logger:warn("Cannot read current floor. Use default value (1).")
	end
end

--Communication setup
peripheral.find("modem", rednet.open)
rednet.host("EV_SYSTEM_MASTER", "master")
Logger:info("Broadcasting EV data to floor computers.")
broadcast(getEVData(), "EV_DATA_RES")
while true do
	local event, sender, message, protocol = os.pullEvent("rednet_message")
	if protocol == "EV_DATA_REQ" then
		--Request to send EV data to the target floor computer.
		Logger:info("Sending EV data to #"..sender..".")
		rednet.send(sender, getEVData(), "EV_DATA_RES")
	elseif protocol == "EV_CALL" then
		--Call elevator to target floor.
		Logger:info("Called to floor "..message..".")
		if message > CurrentFloor then
			--Up
			ElevatorDirection = 1
			broadcast(ElevatorDirection, "EV_DIRECTION")
			redstone.setOutput(Config.clutchFace, true)
			elevatorMove(message)
		elseif message < CurrentFloor then
			--Down
			ElevatorDirection = -1
			broadcast(ElevatorDirection, "EV_DIRECTION")
			redstone.setOutput(Config.clutchFace, true)
			redstone.setOutput(Config.gearShiftFace, true)
			elevatorMove(message)
		else
			rednet.send(sender, {floor = message, isArrived = true}, "EV_FLOOR")
		end
	end
end