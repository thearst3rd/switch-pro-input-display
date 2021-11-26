-- Nintendo Switch Pro Controller Input Display in Love2D
-- by Terry Hearst

local switched = false

local images = {}
local input
local output = {leftx = 0, lefty = 0}


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
	love.graphics.rectangle("fill", x-.5, y-.5, (sideways and 32 or 26)+1, (sideways and 26 or 32)+1)
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
	images.base = love.graphics.newImage("images/base.png")
	images.l = love.graphics.newImage("images/l.png")
	images.r = love.graphics.newImage("images/r.png")
end

local base = 1

function love.joystickadded(joystick)
	input = findJoystick()
end

function love.joystickremoved(joystick)
	input = findJoystick()
end

function love.update(dt)
	-- Poll controller inputs
	if input then
		output.l = input:isGamepadDown("leftshoulder")
		output.r = input:isGamepadDown("rightshoulder")

		output.cup = input:getGamepadAxis("righty") < -0.5
		output.cdown = input:getGamepadAxis("righty") > 0.5
		output.cleft = input:getGamepadAxis("rightx") < -0.5
		output.cright = input:getGamepadAxis("rightx") > 0.5

		output.z = input:getGamepadAxis("triggerleft") > 0.5

		for _, v in pairs{"a", "b", "start", "dpup", "dpdown", "dpleft", "dpright"} do
			output[v] = input:isGamepadDown(v)
		end

		for _, v in pairs{"leftx", "lefty"} do
			output[v] = input:getGamepadAxis(v)
		end
	end
end

function love.draw()
	-- Draw L and R below controller base
	drawBumper(output.l, images.l)
	drawBumper(output.r, images.r)

	-- Draw controller base
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(images.base)

	-- Draw all controller buttons
	drawButton(output.a, 390, 270, 53)
	drawButton(output.b, 342, 221, 53)

	drawButton(output.start, 307, 150, 43)

	drawButton(output.cup, 449, 148, 39)
	drawButton(output.cdown, 449, 225, 39)
	drawButton(output.cleft, 411, 187, 39)
	drawButton(output.cright, 487, 187, 39)

	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", 316, 296 + 32, 26, 26)

	drawDpad(output.dpup, 316, 296)
	drawDpad(output.dpdown, 316, 296 + 32 + 26)
	drawDpad(output.dpleft, 316 - 32, 296 + 32, true)
	drawDpad(output.dpright, 316 + 26, 296 + 32, true)

	drawTrigger(output.z, 186, 34)

	drawAnalog(false, 204, 239, output.leftx, output.lefty)
end
