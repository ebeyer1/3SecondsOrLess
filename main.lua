screenWidth = MOAIEnvironment.screenWidth
screenHeight = MOAIEnvironment.screenHeight
if screenWidth == nil then screenWidth = 480 end
if screenHeight == nil then screenHeight = 800 end

MOAISim.openWindow("Window",screenWidth,screenHeight)

package.path = './moaigui/?.lua;' .. './LuaXml/?.lua;' .. package.path
require("LuaXml")
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

viewport = MOAIViewport.new()
viewport:setSize(screenWidth,screenHeight)
viewport:setScale(screenWidth,screenHeight)

layer = MOAILayer2D.new()
layer:setViewport(viewport)

texture = MOAIImage.new()
texture:load("./gamedata/Default/default.png")

sprite = MOAIGfxQuad2D.new()
sprite:setTexture(texture)
sprite:setRect(-200,-200,200,200)

prop = MOAIProp2D.new()
prop:setDeck(sprite)
prop:setLoc(0,0)
layer:insertProp(prop)

layermgr.addLayer("img",2, layer)
layermgr.addLayer("gui",1, gui:layer())
gui:setTheme("basetheme.lua")
gui:setCurrTextStyle("default")

function onPointerEvent(x, y)
    gui:injectMouseMove(x, y)
end

function onMouseLeftEvent(down)
    if(down) then
        gui:injectMouseButtonDown(inputconstants.LEFT_MOUSE_BUTTON)
    else
        gui:injectMouseButtonUp(inputconstants.LEFT_MOUSE_BUTTON)
    end
end

function onTouchEvent(eventType,idx,x,y,tapCount)
    --gui:injectTouch(eventType,idx,x,y,tapCount)
    onPointerEvent(x, y)
    if (MOAITouchSensor.TOUCH_DOWN == eventType) then
        onMouseLeftEvent(true)
    elseif (MOAITouchSensor.TOUCH_UP == eventType) then
        onMouseLeftEvent(false)
    end
end


if MOAIInputMgr.device.pointer then
    MOAIInputMgr.device.pointer:setCallback(onPointerEvent)
    MOAIInputMgr.device.mouseLeft:setCallback(onMouseLeftEvent)
else
    MOAIInputMgr.device.touch:setCallback(onTouchEvent)
end

function nextGame()
	return math.random(300) % 5 + 1
end

function setupNextGame(gamename)
	-- some pseudo random way of establishing the next game
	local path = "./gamedata/" .. gamename .. "/data.xml"
	local xfile = xml.load(path)

	local currentGame = xfile:find("game")

	if currentGame ~= nil then
		currentTitle = currentGame:find("title")[1]
		currentTimespanMin = currentGame:find("time"):find("min")[1]
		currentTimespanMax = currentGame:find("time"):find("max")[1]
		currentImage = currentGame:find("image")[1]
	end

	currentLabel = "Currently playing: " .. currentTitle .. ", you have " .. currentTimespanMin .. "-" .. currentTimespanMax .. " seconds."
	print(currentLabel)
end

function displayGameData()
	label1:setText(currentLabel)
	texture:load(currentImage)
	sprite:setTexture(texture)
end

function onButtonClick(event,data)
	local fileName = gameList[gameIndex]
	if fileName ~= nil
		setupNextGame(fileName)
		gameIndex = gameIndex + 1
	else
		setupNextGame("Default")
	end
	displayGameData()
end

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

setupNextGame("Default")
displayGameData()
gameIndex = 1

local iter = 1
for file in lfs.dir[[./gamedata]] do
	if file ~= "Default"
		gameList[iter] = file
		iter = iter + 1
	end
end