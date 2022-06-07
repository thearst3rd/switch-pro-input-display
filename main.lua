-- Guitar Hero Controller Input Display in Love2D
-- by Terry Hearst

local input
local output = {analogx = 0, analogy = 0, whammy = 0}


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
	return love.joystick.getJoysticks()[1]
end

local function drawFret(color, pressed, x, y, text)
	local oldR, oldG, oldB, oldA = love.graphics.getColor()

	local newColor = {color[1], color[2], color[3], color[4]}
	if not pressed then
		newColor[1] = newColor[1] * 0.5
		newColor[2] = newColor[2] * 0.5
		newColor[3] = newColor[3] * 0.5
	end
	love.graphics.setColor(newColor[1], newColor[2], newColor[3], newColor[4])

	love.graphics.rectangle("fill", x, y, 120, 50)

	love.graphics.setColor(oldR, oldG, oldB, oldA)

	if text then
		love.graphics.printf(text, x, y + 10, 120, "center")
	end
end


local function drawStrum(color, pressed, x, y, text)
	local oldR, oldG, oldB, oldA = love.graphics.getColor()

	local newColor = {color[1], color[2], color[3], color[4]}
	if not pressed then
		newColor[1] = newColor[1] * 0.5
		newColor[2] = newColor[2] * 0.5
		newColor[3] = newColor[3] * 0.5
	end
	love.graphics.setColor(newColor[1], newColor[2], newColor[3], newColor[4])

	love.graphics.rectangle("fill", x, y, 150, 40)

	love.graphics.setColor(oldR, oldG, oldB, oldA)

	if text then
		love.graphics.printf(text, x, y + 6, 150, "center")
	end
end

local function drawOther(color, pressed, x, y, text)
	local oldR, oldG, oldB, oldA = love.graphics.getColor()

	local newColor = {color[1], color[2], color[3], color[4]}
	if not pressed then
		newColor[1] = newColor[1] * 0.5
		newColor[2] = newColor[2] * 0.5
		newColor[3] = newColor[3] * 0.5
	end
	love.graphics.setColor(newColor[1], newColor[2], newColor[3], newColor[4])

	love.graphics.circle("fill", x + 18, y + 18, 18)
	love.graphics.circle("fill", x + 132 - 18, y + 18, 18)
	love.graphics.rectangle("fill", x + 18, y, 132 - 36, 36)

	love.graphics.setColor(oldR, oldG, oldB, oldA)

	if text then
		love.graphics.printf(text, x, y + 3, 132, "center")
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
	love.graphics.setFont(love.graphics.newFont(24))

	-- Show initial loading screen
	love.graphics.setBackgroundColor(89/255, 157/255, 220/255)
	love.graphics.clear(89/255, 157/255, 220/255)
	love.graphics.print("Loading...")
	love.graphics.present()

	-- Find joystick
	input = findJoystick()
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
		output.green = input:isDown(1)
		output.red = input:isDown(2)
		output.yellow = input:isDown(3)
		output.blue = input:isDown(4)
		output.orange = input:isDown(5)

		output.down = input:isDown(6)
		output.up = input:isDown(9)

		output.plus = input:isDown(7)
		output.minus = input:isDown(8)

		output.analogx = input:getAxis(1)
		output.analogy = input:getAxis(2)

		output.whammy = input:getAxis(3) * 1.2 	-- it doesn't seem to reach all the way to 1.0 on its own
		if output.whammy < 0 then output.whammy = 0 end
		if output.whammy > 1 then output.whammy = 1 end
	end
end

function love.draw()
	love.graphics.setColor(1, 1, 1)
	drawFret({0, 1, 0}, output.green,    10 + (0 * 130), 10, "left")
	drawFret({1, 0, 0}, output.red,      10 + (1 * 130), 10, "right")
	drawFret({1, 1, 0}, output.yellow,   10 + (2 * 130), 10, "jump")
	drawFret({0, 0, 1}, output.blue,     10 + (3 * 130), 10, "power")
	drawFret({1, 0.5, 0}, output.orange, 10 + (4 * 130), 10, "cam left")

	drawStrum({0.5, 0.5, 0.5}, output.up, 30, 80, "back")
	drawStrum({0.5, 0.5, 0.5}, output.down, 30, 80 + 50, "forward")

	drawOther({0.5, 0.5, 0.5}, output.plus, 220, 82, "pause")
	drawOther({0.5, 0.5, 0.5}, output.minus, 220, 82 + 46, "restart")

	love.graphics.push()
		love.graphics.translate(420, 100)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", 0, 0, 200, 50)

		love.graphics.setColor(0.6, 0.6, 0.6)
		love.graphics.rectangle("fill", 200 * (1 - output.whammy), 0, 200 * output.whammy, 50)

		love.graphics.setColor(1, 1, 1)
		love.graphics.printf("cam right", 0, 10, 200, "center")
	love.graphics.pop()
end
