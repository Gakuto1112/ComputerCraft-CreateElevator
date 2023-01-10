Instantiate = require("instantiate")

InstallFloor = Instantiate.instantiate({}, require("install"))

InstallFloor.SourseFile = "floor.lua"
InstallFloor.SubFiles = {"logger.lua"}
InstallFloor.ConfigList = {
	{
		name = "floor",
		desc = "Enter floor number.",
		type = "integer"
	},
	{
		name = "buttonFace",
		desc = "Enter the name of face which connected to elevator button.",
		type = "face"
	},
	{
		name = "doorFace",
		desc = "Enter the name of face which connected to elevator door.",
		type = "face"
	},
	{
		name = "roofFloor",
		desc = "Do you want to display top floor as \"R\"?",
		type = "bool"
	}
}

InstallFloor:setup()