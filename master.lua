---@alias ProtocolType
---| "EV_DATA_REQ"
---| "EV_DATA_RES"
---| "EV_CALL"
---| "EV_DIRECTION"
---| "EV_FLOOR"

--Program configurations
Config = {
	minFloor = 1,
	maxFloor = 10
}

Logger = require("logger")
CurrentFloor = 1
ElevatorDirection = 0

---Gets EV data.
---@return table EVData EV data.
function getEVData()
	return {currentFloor = CurrentFloor, direction = ElevatorDirection, minFloor = Config.minFloor, maxFloor = Config.maxFloor}
end

---Broadcasts to floor computers.
---@param message any The data to send.
---@param protocol ProtocolType The protocol of the sending message.
function broadcast(message, protocol)
	for _, floorComputer in ipairs({rednet.lookup("EV_SYSTEM_FLOOR")}) do
		rednet.send(floorComputer, message, protocol)
	end
end

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
		Logger:info("The elevator called to floor "..message..".")
		if message > CurrentFloor then
			--Up
			broadcast(1, "EV_DIRECTION")
		elseif message < CurrentFloor then
			--Down
			broadcast(-1, "EV_DIRECTION")
		else
			rednet.send(sender, {floor = message, isArrived = true}, "EV_FLOOR")
		end
	end
end