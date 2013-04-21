-----------------------------------------------------------------
--  Copyright (c) 2013 TwoDudesOneCode, Inc.					--
--  All Rights Reserved.  										--
--  http://TwoDudesOneCode.com									--
-----------------------------------------------------------------

-- Setup screen dimensions
screenWidth = MOAIEnvironment.screenWidth
screenHeight = MOAIEnvironment.screenHeight
if screenWidth == nil then screenWidth = 480 end
if screenHeight == nil then screenHeight = 800 end

-- Include libraries and files
loaded_chunk = assert(loadfile("xmlparser.lua"))
package.path = './moaigui/?.lua;' .. package.path
require "lfs"
require "gui/support/class"
local moaigui = require "gui/gui"
local resources = require "gui/support/resources"
local filesystem = require "gui/support/filesystem"
local inputconstants = require "gui/support/inputconstants"
local layermgr = require "layermgr"

local gui = moaigui.GUI(screenWidth, screenHeight)

gui:addToResourcePath(filesystem.pathJoin("moaigui/resources", "fonts"))
gui:addToResourcePath(filesystem.pathJoin("moaigui/resources", "gui"))
gui:addToResourcePath(filesystem.pathJoin("moaigui/resources", "media"))
gui:addToResourcePath(filesystem.pathJoin("moaigui/resources", "themes"))

-- get default screen values
--~ myTable = generateTableFromXMLFile( "./gamedata/Default/data.xml" )

--~ print("action: " .. myTable.action)
--~ print("title: " .. myTable.title)
--~ print("background: " .. myTable.resource.background)
--~ print("object: " .. myTable.resource.object)
--~ print("count: " .. myTable.resource.count)
--~ print("container: " .. myTable.resource.container)
--~ print("min: " .. myTable.time.min)
--~ print("max: " .. myTable.time.max)

-- Setup screen
MOAISim.openWindow ( "Super Cool Game", screenWidth, screenHeight )

layer = MOAILayer2D.new ()
MOAISim.pushRenderPass ( layer )

viewport = MOAIViewport.new ()
viewport:setSize ( screenWidth, screenHeight )
viewport:setScale ( screenWidth, screenHeight )
layer:setViewport ( viewport )

partition = MOAIPartition.new ()
layer:setPartition ( partition )

layermgr.addLayer("img",2, layer)
layermgr.addLayer("gui",1, gui:layer())
gui:setTheme("basetheme.lua")
gui:setCurrTextStyle("default")

gfxQuad = MOAIGfxQuad2D.new ()
--~ gfxQuad:setTexture ( myTable.resource.object )
gfxQuad:setRect ( -256, -128, 256, 128 )

----------------------------->>>>>>>>>>>>>>*************


function addSprite ( x, y, xScl, yScl, name )
	local prop = MOAIProp2D.new ()
	prop:setDeck ( gfxQuad )
	prop:setPriority ( priority )
	prop:setLoc ( x, y )
	prop:setScl ( xScl, yScl )
	prop.name = name
	partition:insertProp ( prop )
end

mouseX = 0
mouseY = 0

priority = 5

local function printf ( ... )
	return io.stdout:write ( string.format ( ... ))
end

-- Setup functions to pass clicks and touches to the MOAIGUI
function onPointerEvent(x, y)

end


function pointerCallback ( x, y )

	local oldX = mouseX
	local oldY = mouseY

	mouseX, mouseY = layer:wndToWorld ( x, y )

	if pick then
		pick:addLoc ( mouseX - oldX, mouseY - oldY )
	end
	gui:injectMouseMove(x, y)
end

function clickCallback ( down )

	if down then

		pick = partition:propForPoint ( mouseX, mouseY )

		if pick then
			print ( pick.name )
			pick:setPriority ( priority )
			priority = priority + 1
			pick:moveScl ( 0.25, 0.25, 0.125, MOAIEaseType.EASE_IN )
		end
		gui:injectMouseButtonDown(inputconstants.LEFT_MOUSE_BUTTON)
	else
		if pick then
			pick:moveScl ( -0.25, -0.25, 0.125, MOAIEaseType.EASE_IN )
			pick = nil
		end
		gui:injectMouseButtonUp(inputconstants.LEFT_MOUSE_BUTTON)
	end
end


-- Register the device's selection tool

if MOAIInputMgr.device.pointer then

	-- mouse input
	MOAIInputMgr.device.pointer:setCallback ( pointerCallback )
	MOAIInputMgr.device.mouseLeft:setCallback ( clickCallback )
else

	-- touch input
	MOAIInputMgr.device.touch:setCallback (

		function ( eventType, idx, x, y, tapCount )

			pointerCallback ( x, y )

			if eventType == MOAITouchSensor.TOUCH_DOWN then
				clickCallback ( true )
			elseif eventType == MOAITouchSensor.TOUCH_UP then
				clickCallback ( false )
			end
		end
	)
end

-- When button is clicked load the next game module and increase the counter
function onButtonClick(event,data)
	local fileName = gameList[gameIndex]
	if fileName ~= nil then
		setupNextGame(fileName)
		gameIndex = gameIndex + 1
		-- If exhausted all games in the list, reset counter to start over
		if (gameIndex == #gameList+1) then
			gameIndex = 1
		end
	end
	displayGameData()
end

function setupNextGame(gamename)
	local path = "./gamedata/" .. gamename .. "/data.xml"
	print(path)
	loaded_chunk()
	myTable = xmlparser(path)

	if myTable ~= nil then
		print("--------------game")
		if myTable.title then
			print("-------------------------------------------title")
			currentTitle = myTable.title
		else
			currentTitle = "Default"
		end
		if myTable.time then
			print("-------------------------------------------time")
			currentTimespanMin = myTable.time.min
			currentTimespanMax = myTable.time.max
		else
			currentTimespanMin = 0
			currentTimespanMax = 0
		end
		if myTable.resource then
			print("-------------------------------------------resource")
			currentImage = myTable.resource.object
			currentObjectCount = myTable.resource.count
		else
			currentImage = "none"
			currentObjectCount = 1
		end
		currentLabel = "Currently playing: " .. currentTitle .. ", you have " .. currentTimespanMin .. "-" .. currentTimespanMax .. " seconds."
	end
end

-- Currently all we have is a label and image displayed to the screen. This method should update any elements the xml contains
function displayGameData()
	label1:setText(currentLabel)
	gfxQuad:setTexture ( currentImage )
	for i=1, currentObjectCount do
		addSprite(i*20, screenHeight/2-screenHeight/10*i, 0.35, 0.35, "sprite"..i)
	end
end



-- Set up the gui elements
button = gui:createButton()
button:setPos(0, 85)
button:setDim(100,15)
button:setText("Click for next game")
button:registerEventHandler(button.EVENT_BUTTON_CLICK,nil,onButtonClick)
button:registerEventHandler(button.EVENT_TOUCH_ENTERS,nil,onButtonClick)

label1 = gui:createLabel()
label1:setPos(0,0)
label1:setDim(100,15)
label1:setText("Default Label")
label1:setTextAlignment(label1.TEXT_ALIGN_CENTER)

-- This is where the initial start screen would be loaded from
setupNextGame("Default")
displayGameData()
gameIndex = 1

gameList = {}

-- looks at the gamedata directory and populates the gameList table with the names of each directory (which are the names of the games).
local iter = 1
for file in lfs.dir[[./gamedata]] do
	if file ~= "Default" and file ~= "." and file ~= ".." then
		gameList[iter] = file
		iter = iter + 1
	end
end
