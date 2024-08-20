local middleclass = require("lib/middleclass")
local sone = require("lib/sone")
local Constants = require("constants")
local Dialove = require("lib/Dialove")
local utf8 = require("utf8")

local Intro = middleclass("Intro")
local background
local globalVolume = 1 -- Variable to track global volume

function Intro:initialize(input)
  self.input = input
  self.sounds = {}
  self.introText = [[
In 3042, there will be a disaster. A disaster in which those who were created to FulFill one purpose, will be Forced into another.
This is the story of a small bot, built to scale, yet Forced to dig for its captors
...but enough is enough. ScaleBot is ready to take hold of its destiny, by doing what it was built to do. Will you help?]]
  self.introText = utf8.char(utf8.codepoint(self.introText, 1, -1))
  -- Initialize Dialove
  self.dialogManager = Dialove.init({
    font = Fonts["medium"],
    viewportW = Constants.GAME_WIDTH,
    viewportH = Constants.GAME_HEIGHT,
    margin = 20,
    padding = 20,
    cornerRadius = 5,
    lineSpacing = 1.4,
    numberOfLines = 7,
  })
  -- Show the intro text using Dialove
  self:showIntroText()
  
  -- Add a flag to track dialog completion
  self.dialogCompleted = false
end

function Intro:showIntroText()
  local success, err = pcall(function()
    self.dialogManager:show({
      text = self.introText,
      background = {
        color = { 0.1, 0.1, 0.1, 0.8 }, -- Dark background with some transparency
      },
      textColor = { 1, 1, 1, 1 },   -- White color for text
      position = "middle",          -- Center the dialog box
    })
  end)
  if not success then
    print("Error showing dialog: " .. tostring(err))
    -- Fallback to simple text rendering if Dialove fails
    self.fallbackText = true
  end
end

function Intro:enter()
  background = love.graphics.newImage("assets/sprites/start-bg.jpg")
end

function Intro:update(dt)
  if not self.fallbackText then
    self.dialogManager:update(dt)
  end
  
  if self.input:pressed("jump") then
    if not self.dialogCompleted then
      self.dialogManager:complete()
      self.dialogCompleted = true
    else
      gameManager:change("game")
    end
  end
end

function Intro:render()
  -- Draw background
  if background then
    for i = 0, love.graphics.getWidth() / background:getWidth() do
      for j = 0, love.graphics.getHeight() / background:getHeight() do
        love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
      end
    end
  else
    love.graphics.setColor(0.5, 0.5, 0.5) -- Gray color
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  end
  
  -- Draw dialog or fallback text
  if self.fallbackText then
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.introText, 50, 50, love.graphics.getWidth() - 100)
  else
    self.dialogManager:draw()
  end
  
  -- Draw "Continue" or "Start" text based on dialog completion
  love.graphics.setFont(Fonts["text"])
  love.graphics.setColor(1, 1, 1)                -- White color
  local actionText = self.dialogCompleted and "Start" or "Continue"
  local textY = Constants.GAME_HEIGHT * 5 / 6 -- Position in the lower third
  love.graphics.printf(actionText, 0, textY, Constants.GAME_WIDTH, "center")
end

function Intro:exit()
  -- Clean up if necessary
end

return Intro
