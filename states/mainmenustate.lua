local middleclass = require("lib/middleclass")
local sone = require("lib/sone")
local Constants = require("constants")
local MainMenu = middleclass("MainMenu")

local buttonHeight = 24
local volumeButtonWidth = 30 -- Smaller width for volume buttons
local selectedButton = 1
local background
local globalVolume = 1 -- Variable to track global volume

local function newButton(text, fn, width)
  return {
    text = text,
    fn = fn,
    width = width or 128, -- Default width if not specified
  }
end

local buttons = {}
local volumeButtons = {}

function MainMenu:initialize(input)
  self.input = input
  self.sounds = {}
end

function MainMenu:enter()
  self.sounds.music = Sounds["music"]
  self.sounds.music:setLooping(true)
  self.sounds.music:play()
  volumeButtons = {
    newButton("-", function()
      globalVolume = math.max(globalVolume - 0.1, 0)
      self.sounds.music:setVolume(globalVolume)
    end, volumeButtonWidth),
    newButton("+", function()
      globalVolume = math.min(globalVolume + 0.1, 1)
      self.sounds.music:setVolume(globalVolume)
    end, volumeButtonWidth),
  }

  buttons = {
    newButton("START GAME", function()
      gameManager:change("intro", { bfl = false })
    end),
    newButton("EXIT", function()
      love.event.quit(0)
    end),
  }

  background = love.graphics.newImage("assets/sprites/start-bg.jpg")
end

function MainMenu:update(dt)
  if self.input:pressed("up") then
    if selectedButton > 2 then
      selectedButton = selectedButton - 1
    elseif selectedButton == 2 then
      selectedButton = #volumeButtons -- Move to volume buttons
    end
  elseif self.input:pressed("down") then
    if selectedButton < #buttons + #volumeButtons then
      selectedButton = selectedButton + 1
    end
  elseif self.input:pressed("left") or self.input:pressed("right") then
    if selectedButton <= #volumeButtons then
      selectedButton = (selectedButton == 1) and 2 or 1
    end
  end

  if self.input:pressed("select") then
    if selectedButton <= #volumeButtons then
      volumeButtons[selectedButton].fn()
    else
      buttons[selectedButton - #volumeButtons].fn()
    end
  end
end

function MainMenu:render()
  -- Draw background
  for i = 0, love.graphics.getWidth() / background:getWidth() do
    for j = 0, love.graphics.getHeight() / background:getHeight() do
      love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
    end
  end

  -- Draw title
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(Fonts["large"])
  love.graphics.setColor(0, 0, 0, 0.8)
  love.graphics.printf(
    "SCALEBOT 9000",
    2,
    50 + 2,
    Constants.GAME_WIDTH * 0.77 + 2,
    "center",
    0,
    1.3,
    1.3
  )
  love.graphics.setColor(127 / 255, 168 / 255, 159 / 255, 1)
  love.graphics.printf(
    "SCALEBOT 9000",
    2,
    50,
    Constants.GAME_WIDTH * 0.77,
    "center",
    0,
    1.3,
    1.3
  )

  -- Draw volume controls
  love.graphics.setFont(Fonts["small"])
  local volumeY = Constants.GAME_HEIGHT * 0.4
  love.graphics.printf("Volume:", 0, volumeY, Constants.GAME_WIDTH, "center")

  local totalVolumeWidth = volumeButtonWidth * 2 + 20 -- 20 px spacing between buttons
  local volumeStartX = (Constants.GAME_WIDTH - totalVolumeWidth) / 2

  for i, button in ipairs(volumeButtons) do
    local bx = volumeStartX + (i - 1) * (volumeButtonWidth + 20)
    local by = volumeY + 30 -- AND THIS LINE
    local color = (selectedButton == i) and { 249 / 255, 166 / 255, 34 / 255, 1 }
        or { 127 / 255, 168 / 255, 159 / 255, 1 }
    love.graphics.setColor(unpack(color))
    love.graphics.rectangle("fill", bx, by, button.width, buttonHeight)
    love.graphics.setColor(1, 1, 1, 1)
    local textW = love.graphics.getFont():getWidth(button.text)
    love.graphics.print(button.text, bx + (button.width - textW) / 2, by + 7)
  end

  -- Draw main menu buttons
  love.graphics.setFont(Fonts["medium"])
  local vertMargin = 4
  local totalHeight = (buttonHeight + vertMargin) * #buttons
  local cursorY = 0
  for i, button in ipairs(buttons) do
    local bx = (Constants.GAME_WIDTH * 0.5) - (button.width * 0.5)
    local by = (Constants.GAME_HEIGHT * 0.7) - (totalHeight * 0.5) + cursorY
    local color = (selectedButton == i + #volumeButtons) and { 249 / 255, 166 / 255, 34 / 255, 1 }
        or { 127 / 255, 168 / 255, 159 / 255, 1 }
    love.graphics.setColor(unpack(color))
    love.graphics.rectangle("fill", bx, by, button.width, buttonHeight)
    local textW = love.graphics.getFont():getWidth(button.text)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(button.text, bx + (button.width - textW) / 2, by + 5)
    cursorY = cursorY + (buttonHeight + vertMargin)
  end

  -- Draw instructions and current volume
  love.graphics.setFont(Fonts["text"])
  love.graphics.setColor(1, 1, 1, 0.8)

  love.graphics.printf(
    string.format("Current Volume: %d%%", math.floor(globalVolume * 100)),
    0,
    Constants.GAME_HEIGHT / 2 + 140,
    Constants.GAME_WIDTH,
    "center"
  )
end

function MainMenu:exit() end

return MainMenu
