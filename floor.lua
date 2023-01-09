--Program configurations
Config = {
	floor = 1 --The floor of this floor computer.
}

---Draws centered text in line.
---@param text string A string to print.
function drawFloorNumber(text)
	Monitor.setCursorPos(1, 3)
	Monitor.write("     ")
	Monitor.setCursorPos(3 - math.floor(#text), 3)
	Monitor.write(text)
end

---Draws direction arrow.
---@param direction number Arrow direction: 1: up, 0: none (the elevetor is stopping), -1: down
function drawArrow(direction)
	for _, cursorPos in ipairs({{3, 1}, {3, 3}}) do
		Monitor.setCursorPos(cursorPos[1], cursorPos[2])
		Monitor.write(" ")
	end
	local isColor = Monitor.isColor()
	if direction == 1 then
		if isColor then
			Monitor.setTextColor(colors.lime)
		end
		Monitor.setCursorPos(3, 1)
		Monitor.write("=")
	elseif direction == -1 then
		if isColor then
			Monitor.setTextColor(colors.red)
		end
		Monitor.setCursorPos(3, 3)
		Monitor.write("=")
	end
	if direction ~= 0 and isColor then
		Monitor.setTextColor(colors.white)
	end
end

Logger = require("logger")

--Setup
Logger:info("This floor is "..Config.floor..".")
Monitor = peripheral.find("monitor")
Monitor.clear()
Monitor.setTextScale(1.5)
Monitor.setCursorPos(3, 2)
Monitor.write("?")
peripheral.find("modem", rednet.open)
rednet.host("EV_SYSTEM_FLOOR", "floor_"..Config.floor)

--Search for master computer
MasterID = nil
repeat
	local id = rednet.lookup("EV_SYSTEM_MASTER")
	if id then
		Logger:info("Found the master computer.")
		MasterID = id
	else
		Logger:error("Cannot find the master computer. Search again after 5 seconds.")
		sleep(5)
	end
until MasterID

--Initial communication
Logger:info("Sending EV data request to master.")
rednet.send(MasterID, "", "EV_DATA_REQ")

--Event
while true do
	local event, sender, message, protocol = os.pullEvent("rednet_message")
	if protocol == "EV_DATA_RES" then
		Logger:info("Got EV data from master.")
		drawFloorNumber(tostring(message.currentFloor))
		drawArrow(message.direction)
	end
end