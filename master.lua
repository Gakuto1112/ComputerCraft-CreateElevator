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
		rednet.send(sender, {currentFloor = CurrentFloor, direction = Direction, minFloor = Config.minFloor, maxFloor = Config.maxFloor}, "EV_DATA_RES")
	end
end