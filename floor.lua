--Program configurations
Config = {
	buttonFace = "back", --The face with elevator call button.
	floor = 1 --The floor of this floor computer.
}

Logger = require("logger")
FloorRange = {0, 0} --Floor range: 1. minimum floor, 2. maximum floor
ElevatorDirection = 0 --Direction of the elevator: 1. up, 0. stopped, -1. down
IsDirectionIndicated = false --Whatever the direction indicators are displayed or not.

---Resets floor input screen.
function resetFloorInputScreen()
	term.clear()
	term.setCursorPos(1, 1)
	if ElevatorDirection == 0 then
		print("Enter the floor which you want to go ("..FloorRange[1].."-"..FloorRange[2]..").")
		write("> ")
	else
		print("The elevator is moving. Please wait.")
	end
	term.setCursorBlink(ElevatorDirection == 0)
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
function drawArrow()
	for _, cursorPos in ipairs({{3, 1}, {3, 3}}) do
		Monitor.setCursorPos(cursorPos[1], cursorPos[2])
		Monitor.write(" ")
	end
	local isColor = Monitor.isColor()
	if ElevatorDirection == 1 then
		if isColor then
			Monitor.setTextColor(colors.lime)
		end
		Monitor.setCursorPos(3, 1)
		Monitor.write("=")
	elseif ElevatorDirection == -1 then
		if isColor then
			Monitor.setTextColor(colors.red)
		end
		Monitor.setCursorPos(3, 3)
		Monitor.write("=")
	end
	if ElevatorDirection ~= 0 and isColor then
		Monitor.setTextColor(colors.white)
	end
	IsDirectionIndicated = true
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

--Search for master computerElevatorDirection
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
		drawArrow()
		FloorRange = {message.minFloor, message.maxFloor}
		resetFloorInputScreen()
		break
	end
end

--Parallel functions
ParallelData = nil

function floorInput()
	if ElevatorDirection == 0 then
		ParallelData = tonumber(read())
	else
		while true do
			sleep(0.5)
			if ElevatorDirection <= 1 then
				Monitor.setCursorPos(3, ElevatorDirection == 1 and 1 or 3)
				local isColor = Monitor.isColor()
				if isColor then
					Monitor.setTextColor(ElevatorDirection == 1 and colors.lime or colors.red)
				end
				Monitor.write(IsDirectionIndicated and " " or "=")
				if isColor then
					Monitor.setTextColor(colors.white)
				end
				IsDirectionIndicated = not IsDirectionIndicated
			end
		end
	end
end

function eventStandby()
	while true do
		local event, arg1, arg2, arg3 = os.pullEvent()
		if event == "rednet_message" or event == "redstone" then
			ParallelData = {event, arg1, arg2, arg3}
			return
		end
	end
end

while true do
	local functionNumber = parallel.waitForAny(floorInput, eventStandby)
	if functionNumber == 1 then
		if ParallelData and ParallelData % 1 == 0 and ParallelData >= FloorRange[1] and ParallelData <= FloorRange[2] then
			rednet.send(MasterID, ParallelData, "EV_CALL")
			ElevatorDirection = 2
		else
			local isColor = term.isColor()
			if isColor then
				term.setTextColor(colors.red)
			end
			print("Invalid input. Reason: not number, not integer, or out of range")
			if isColor then
				term.setTextColor(colors.white)
			end
			write("> ")
		end
	elseif functionNumber == 2 then
		if ParallelData[1] == "rednet_message" then
			if ParallelData[4] == "EV_DIRECTION" then
				ElevatorDirection = ParallelData[3]
				drawArrow()
				resetFloorInputScreen()
			elseif ParallelData[4] == "EV_FLOOR" then
				drawFloorNumber(tostring(ParallelData[3].floor))
				if ParallelData[3].isArrived then
					ElevatorDirection = 0
					drawArrow()
					resetFloorInputScreen()
				end
			end
		elseif ParallelData[1] == "redstone" then
			if redstone.getInput(Config.buttonFace) and ElevatorDirection == 0 then
				rednet.send(MasterID, Config.floor, "EV_CALL")
			end
		end
	end
end