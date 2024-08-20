local middleclass = require("lib/middleclass")

local Constants = require("constants")
local WinState = middleclass("WinState")

local joystick
local usingGamepad

function WinState:initialize(input)
  self.input = input
  self.font = love.graphics.newFont("assets/fonts/Nippo-Bold.ttf", 32)
  self.sounds = {}
end

function WinState:enter()
  joystick = love.joystick.getJoysticks()[1]
  if joystick then
    usingGamepad = joystick:isGamepad()
  end
end

function WinState:update(dt)
  if self.input:pressed("gameExit") then
    love.event.quit()
  end
  if self.input:pressed("gameStart") then
    gameManager:change("main_menu")
  end
end

function WinState:render()
  love.graphics.setFont(self.font)
  love.graphics.setColor(1, 0, 0, 1)
  love.graphics.printf("YOU WIN", 2, Constants.GAME_HEIGHT / 2 - 60, Constants.GAME_WIDTH, "center")
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf("Start Over", 0, Constants.GAME_HEIGHT / 2 + 64, Constants.GAME_WIDTH, "center")
end

function WinState:exit()
  -- Add any cleanup logic when exiting this state
end

return WinState
