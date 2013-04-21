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
require("parser")

-- get default screen values
myTable = generateTableFromXMLFile( "./gamedata/BaconFry/data.xml" )

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

gfxQuad = MOAIGfxQuad2D.new ()
gfxQuad:setTexture ( myTable.resource.object )
gfxQuad:setRect ( -256, -128, 256, 128 )


--~ print("action: " .. myTable.action)
--~ print("title: " .. myTable.title)
--~ print("background: " .. myTable.resource.background)
--~ print("object: " .. myTable.resource.object)
--~ print("count: " .. myTable.resource.count)
--~ print("container: " .. myTable.resource.container)
--~ print("min: " .. myTable.time.min)
--~ print("max: " .. myTable.time.max)

function addSprite ( x, y, xScl, yScl, name )
	local prop = MOAIProp2D.new ()
	prop:setDeck ( gfxQuad )
	prop:setPriority ( priority )
	prop:setLoc ( x, y )
	prop:setScl ( xScl, yScl )
	prop.name = name
	partition:insertProp ( prop )
end

for i=1, myTable.resource.count do
	addSprite(i*20, screenHeight/2-screenHeight/10*i, 0.35, 0.35, "sprite"..i)
end

mouseX = 0
mouseY = 0

priority = 5

local function printf ( ... )
	return io.stdout:write ( string.format ( ... ))
end

function pointerCallback ( x, y )

	local oldX = mouseX
	local oldY = mouseY

	mouseX, mouseY = layer:wndToWorld ( x, y )

	if pick then
		pick:addLoc ( mouseX - oldX, mouseY - oldY )
	end
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
	else
		if pick then
			pick:moveScl ( -0.25, -0.25, 0.125, MOAIEaseType.EASE_IN )
			pick = nil
		end
	end
end

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
