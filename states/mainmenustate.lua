local middleclass = require("lib/middleclass")
local sone = require("lib/sone")

local Constants = require("constants")
local MainMenu = middleclass("MainMenu")

local joystick
local usingGamepad

function MainMenu:initialize(input)
  self.input = input
  self.sounds = {}
end

function MainMenu:enter()
  joystick = love.joystick.getJoysticks()[1]
  if joystick then
    usingGamepad = joystick:isGamepad()
  end

  self.sounds.music = love.audio.newSource("assets/audio/music/MegaHyperUltrastorm.mp3", "static")
  -- self.sounds.music:play()
end

function MainMenu:update(dt)
  if self.input:pressed("gameExit") then
    love.event.quit()
  end
  if self.input:pressed("gameStart") then
    gameManager:change("game")
  end
end

function MainMenu:render()
  love.graphics.clear(0.4, 0.7, 1, 1)
  love.graphics.setColor(1, 1, 1, 1) -- Reset color to white

  love.graphics.setFont(Fonts["large"])
  love.graphics.setColor(0.1, 0.4, 0.5, 1)
  love.graphics.printf("SCALEBOT 9000", 2, Constants.GAME_HEIGHT / 2 - 60, Constants.GAME_WIDTH, "center")

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(Fonts["medium"])
  if usingGamepad then
    love.graphics.printf("Press A", 0, Constants.GAME_HEIGHT / 2 + 64, Constants.GAME_WIDTH, "center")
  elseif not usingGamepad then
    love.graphics.printf("Press Enter", 0, Constants.GAME_HEIGHT / 2 + 64, Constants.GAME_WIDTH, "center")
  end
end

function MainMenu:exit()
  -- Add any cleanup logic when exiting this state
end

return MainMenu
