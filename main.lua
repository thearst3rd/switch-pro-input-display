-- Nintendo Switch Pro Controller Input Display in Love2D
-- by Terry Hearst

local switched = false

local images = {}
local input
local output = {leftx = 0, lefty = 0, rightx = 0, righty = 0}


-----------------------------
-- ALLOW BACKGROUND INPUTS --
-----------------------------

local ffi = require("ffi")

ffi.cdef[[
typedef enum
{
	SDL_FALSE = 0,
	SDL_TRUE = 1
} SDL_bool;

SDL_bool SDL_SetHint(const char *name, const char *value);
]]

local sdl = ffi.os == "Windows" and ffi.load("SDL2") or ffi.C

sdl.SDL_SetHint("SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS", "1")


----------------------
-- HELPER FUNCTIONS --
----------------------

pressedColor = {.2, 1, .2}
defaultColor = {1, 1, 1}

local function findJoystick()
	for i, joystick in ipairs(love.joystick.getJoysticks()) do
		if joystick:isGamepad() then return joystick end
	end
	return nil
end

local function drawButton(pressed, x, y, diameter)
	diameter = diameter or 52
	love.graphics.setColor(pressed and pressedColor or defaultColor)
	love.graphics.circle("fill", x + diameter/2, y + diameter/2, diameter/2)
end

local function drawScreenshotButton(pressed, x, y)
	love.graphics.setColor(pressed and pressedColor or defaultColor)
	love.graphics.rectangle("fill", x-.5, y-.5, 27+1, 27+1)
end

local function drawDpad(pressed, x, y, sideways)
	love.graphics.setColor(pressed and pressedColor or defaultColor)
	love.graphics.rectangle("fill", x-.5, y-.5, (sideways and 36 or 33)+1, (sideways and 33 or 36)+1)
end

local function drawBumper(pressed, image)
	love.graphics.setColor(pressed and pressedColor or defaultColor)
	love.graphics.draw(image)
end

local function drawTrigger(pressed, x, y, zr)
	if pressed then
		love.graphics.push()
			love.graphics.setColor(pressedColor)
			love.graphics.translate(x, y)
			love.graphics.rotate(zr and 0.2 or -0.2)
			love.graphics.rectangle("fill", -29, -20, 58, 40)
		love.graphics.pop()
	end
end

local function drawAnalog(pressed, cx, cy, ax, ay)
	love.graphics.setColor(pressed and pressedColor or defaultColor)
	love.graphics.circle("fill", cx + (24 * ax), cy + (24 * ay), 41)
end


--------------------
-- LOVE CALLBACKS --
--------------------

function love.load()
	-- Show initial loading screen
	love.graphics.setBackgroundColor(89/255, 157/255, 220/255)
	love.graphics.clear(89/255, 157/255, 220/255)
	love.graphics.print("Loading...")
	love.graphics.present()

	-- Find joystick
	input = findJoystick()

	-- Load images
	images.base = love.graphics.newImage("images/ProOverlay.png")
	images.l = love.graphics.newImage("images/L.png")
	images.r = love.graphics.newImage("images/R.png")
end

local base = 1

function love.keypressed(key, scancode, isrepeat)
	if key == "x" then
		switched = not switched
	elseif key == "a" then
		switched = false
	elseif key == "b" then
		switched = true
	end
end

function love.joystickadded(joystick)
	input = findJoystick()
end

function love.joystickremoved(joystick)
	input = findJoystick()
end

function love.update(dt)
	-- Poll controller inputs
	if input then
		output.a = input:isGamepadDown(switched and "a" or "b")
		output.b = input:isGamepadDown(switched and "b" or "a")
		output.x = input:isGamepadDown(switched and "x" or "y")
		output.y = input:isGamepadDown(switched and "y" or "x")

		output.plus = input:isGamepadDown("start")
		output.minus = input:isGamepadDown("back")
		output.home = input:isGamepadDown("guide")
		output.screenshot = false 	-- No way to detect with Magic-NS on XInput mode

		output.l = input:isGamepadDown("leftshoulder")
		output.r = input:isGamepadDown("rightshoulder")

		output.zl = input:getGamepadAxis("triggerleft") > 0.5
		output.zr = input:getGamepadAxis("triggerright") > 0.5

		for _, v in pairs{"leftstick", "rightstick", "dpup", "dpdown", "dpleft", "dpright"} do
			output[v] = input:isGamepadDown(v)
		end

		for _, v in pairs{"leftx", "lefty", "rightx", "righty"} do
			output[v] = input:getGamepadAxis(v)
		end
	end
end

function love.draw()
	-- Draw controller base
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(images.base)

	-- Draw all controller buttons
	drawButton(output.a, 618, 176)
	drawButton(output.b, 562, 224)
	drawButton(output.x, 562, 128)
	drawButton(output.y, 506, 176)

	drawButton(output.plus, 472, 132, 30)
	drawButton(output.minus, 295, 132, 30)
	drawButton(output.home, 434, 186, 30)
	drawScreenshotButton(output.screenshot, 335, 188)

	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", 272, 248, 33, 105)
	love.graphics.rectangle("fill", 236, 284, 105, 33)

	drawDpad(output.dpup, 272, 248)
	drawDpad(output.dpdown, 272, 248 + 105 - 36)
	drawDpad(output.dpleft, 236, 284, true)
	drawDpad(output.dpright, 236 + 105 - 36, 284, true)

	drawBumper(output.l, images.l)
	drawBumper(output.r, images.r)

	drawTrigger(output.zl, 186, 34)
	drawTrigger(output.zr, 610, 34, true)

	drawAnalog(output.leftstick, 202, 202, output.leftx, output.lefty)
	drawAnalog(output.rightstick, 493, 301, output.rightx, output.righty)
end
