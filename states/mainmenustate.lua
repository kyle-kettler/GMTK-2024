local middleclass = require("lib/middleclass")
local push = require("lib/push")
local sone = require("lib/sone")
local Constants = require("constants")
local MainMenu = middleclass("MainMenu")

local buttonHeight = 24
local selectedButton = 1

local function newButton(text, fn)
  return {
    text = text,
    fn = fn,
  }
end

local buttons = {}

function MainMenu:initialize(input)
  self.input = input
  self.sounds = {}
end

function MainMenu:enter()
  buttons = {
    newButton("START GAME", function()
      gameManager:change("game")
    end),
    newButton("EXIT", function()
      love.event.quit(0)
    end),
  }
  
  self.sounds.music = love.audio.newSource("assets/audio/music/MegaHyperUltrastorm.mp3", "static")
  -- self.sounds.music:play()
end

function MainMenu:update(dt)
  if self.input:pressed("up") then
    selectedButton = math.max(1, selectedButton - 1)
  elseif self.input:pressed("down") then
    selectedButton = math.min(#buttons, selectedButton + 1)
  end

  if self.input:pressed("select") then
    buttons[selectedButton].fn()
  end
end

function MainMenu:render()
  love.graphics.clear(0.4, 0.7, 1, 1)
  love.graphics.setColor(1, 1, 1, 1) -- Reset color to white
  love.graphics.setFont(Fonts["large"])
  love.graphics.setColor(0.1, 0.4, 0.5, 1)
  love.graphics.printf("SCALEBOT 9000", 2, Constants.GAME_HEIGHT / 2 - 100, Constants.GAME_WIDTH, "center")
  
  local buttonWidth = 128
  local vertMargin = 4
  local totalHeight = (buttonHeight + vertMargin) * #buttons
  local cursorY = 0
  
  love.graphics.setFont(Fonts["small"])
  for i, button in ipairs(buttons) do
    local bx = (Constants.GAME_WIDTH * 0.5) - (buttonWidth * 0.5)
    local by = (Constants.GAME_HEIGHT * 0.7) - (totalHeight * 0.5) + cursorY
    local color = { 0.1, 0.4, 0.5, 1 }
    
    if i == selectedButton then
      color = { 0.2, 0.5, 0.6, 1 }
    end
    
    love.graphics.setColor(unpack(color))
    love.graphics.rectangle("fill", bx, by, buttonWidth, buttonHeight)
    
    local font = love.graphics.getFont()
    local textW = font:getWidth(button.text)
    love.graphics.setColor(1, 1, 1, 1) -- Reset color to white
    love.graphics.print(button.text, (Constants.GAME_WIDTH * 0.5) - textW * 0.5, by + 9)
    
    cursorY = cursorY + (buttonHeight + vertMargin)
  end
  
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(Fonts["small"])
  love.graphics.printf(
    "Use Up/Down to navigate, Select to choose",
    0,
    Constants.GAME_HEIGHT / 2 + 100,
    Constants.GAME_WIDTH,
    "center"
  )
end

function MainMenu:exit()
  -- Add any cleanup logic when exiting this state
end

return MainMenu
