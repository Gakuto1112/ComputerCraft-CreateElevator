--Program configurations
Config = {
	minFloor = 1,
	maxFloor = 10
}

local Logger = require("logger")

CurrentFloor = 1
Direction = 1

peripheral.find("modem", rednet.open)
rednet.host("EV_SYSTEM_MASTER", "master")
while true do
	local event, sender, message, protocol = os.pullEvent("rednet_message")
	if protocol == "EV_DATA_REQ" then
		Logger:info("Sending EV data to #"..sender..".")
		rednet.send(sender, {currentFloor = CurrentFloor, direction = Direction}, "EV_DATA_RES")
	elseif protocol == "EV_CALL" then
		local floor = tonumber(message)
		if floor >= Config.minFloor and floor <= Config.maxFloor then
			--TODO: move elevator.
		else
			Logger:warn("One of the floor computers tried to call elevator to floor "..message..", but it does not exist.")
			rednet.send(sender, "", "EV_CALL_INVALID")
		end
	end
end