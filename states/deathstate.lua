local middleclass = require("lib/middleclass")

local Constants = require("constants")
local DeathState = middleclass("DeathState")

local joystick
local usingGamepad

function DeathState:initialize(input)
  self.input = input
  self.sounds = {}
end

function DeathState:enter()
  joystick = love.joystick.getJoysticks()[1]
  if joystick then
    usingGamepad = joystick:isGamepad()
  end
end

function DeathState:update(dt)
  if self.input:pressed("gameExit") then
    love.event.quit()
  end
  if self.input:pressed("gameStart") then
    gameManager:change("game")
  end
end

function DeathState:render()
  love.graphics.setFont(Fonts["large"])
  love.graphics.setColor(1, 0, 0, 1)
  love.graphics.printf("YOU DIED", 2, Constants.GAME_HEIGHT / 2 - 60, Constants.GAME_WIDTH, "center")
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf("Press A to try again", 0, Constants.GAME_HEIGHT / 2 + 64, Constants.GAME_WIDTH, "center")
end

function DeathState:exit()
  -- Add any cleanup logic when exiting this state
end

return DeathState
