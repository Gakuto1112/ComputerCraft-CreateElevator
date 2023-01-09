--Program configurations
Config = {
	buttonFace = "back", --The face with elevator call button.
	floor = 1 --The floor of this floor computer.
}

Logger = require("logger")
FloorRange = {0, 0} --Floor range: 1. minimum floor, 2. maximum floor
IsElevatorMoving = false --Whatever the elevator is moving or not.

---Resets floor input screen.
function resetFloorInputScreen()
	term.clear()
	term.setCursorPos(1, 1)
	if IsElevatorMoving then
		print("The elevator is moving. Please wait.")
	else
		print("Enter the floor which you want to go ("..FloorRange[1].."-"..FloorRange[2]..").")
	end
end

---Draws centered text in line.
---@param text string A string to print.
function drawFloorNumber(text)
	Monitor.setCursorPos(1, 2)
	Monitor.write("     ")
	Monitor.setCursorPos(3 - math.floor(#text / 2), 2)
	Monitor.write(text)
end

---Draws direction arrow.
---@param direction number Arrow direction: 1: up, 0: none (the elevator is stopping), -1: down
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

--Initial event
while true do
	local event, sender, message, protocol = os.pullEvent("rednet_message")
	if protocol == "EV_DATA_RES" then
		Logger:info("Got EV data from master.")
		drawFloorNumber(tostring(message.currentFloor))
		drawArrow(message.direction)
		FloorRange = {message.minFloor, message.maxFloor}
		resetFloorInputScreen()
		break
	end
end

--Parallel functions
function floorInput()
	while true do
		write("> ")
		local floor = tonumber(read())
		if floor and floor % 1 == 0 and floor >= FloorRange[1] and floor <= FloorRange[2] then
			term.setCursorBlink(false)
			rednet.send(MasterID, floor, "EV_CALL")
		else
			local isColor = term.isColor()
			if isColor then
				term.setTextColor(colors.red)
			end
			print("Invalid input.")
			if isColor then
				term.setTextColor(colors.white)
			end
		end
	end
end

function event()
	while true do
		local event, arg1, arg2, arg3 = os.pullEvent()
		if event == "rednet_message" then --arg1: sender, arg2: message, arg3: protocol
		elseif event == "redstone" then
			if redstone.getInput(Config.buttonFace) then
				rednet.send(MasterID, Config.floor, "EV_CALL")
			end
		end
	end
end

parallel.waitForAny(floorInput, event)