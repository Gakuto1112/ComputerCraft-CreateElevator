Instantiate = require("instantiate")

InstallMaster = Instantiate.instantiate({}, require("install"))

InstallMaster.SourseFile = "master.lua"
InstallMaster.SubFiles = {"logger.lua"}
InstallMaster.ConfigList = {
	{
		name = "minFloor",
		desc = "Enter lowest floor number.",
		type = "integer"
	},
	{
		name = "maxFloor",
		desc = "Enter highest floor number.",
		type = "integer"
	},
	{
		name = "timeBetweenFloors",
		desc = "Enter the time required for the elevator to move one floor.",
		type = "number"
	},
	{
		name = "clutchFace",
		desc = "Enter the name of face which contorls clutch with redstone.",
		type = "face"
	},
	{
		name = "gearShiftFace",
		desc = "Enter the name of face which contorls gear shift with redstone.",
		type = "face"
	}
}

InstallMaster:setup()