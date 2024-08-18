local middleclass = require("lib/middleclass")
local Constants = require("constants")

local GUI = middleclass("GUI")

function GUI:initialize(player)
  self.player = player
  self:load()
end

function GUI:load()
  self.launch = {}
  self.launch.color = { 1, 0, 0, 0.7 } -- Red color with some transparency
  self.launch.x = 0
  self.launch.y = Constants.GAME_HEIGHT - 10
  self.launch.width = 5
  self.launch.height = 5
  self.launch.scale = 2
  self.launch.spacing = self.launch.width * self.launch.scale + 5

  self.health = {}
  self.health.color = { 0.5, 0.7, 1, 1 }
  self.health.x = 0
  self.health.y = 10
  self.health.width = 5
  self.health.height = 5
  self.health.scale = 2
  self.health.spacing = self.launch.width * self.launch.scale + 5

  self.score = 0
  self.displayedScore = 0
  self.targetScore = 0
  self.scoreIncreaseSpeed = 30
end

function GUI:update(dt)
  self:updateScore(dt)
end

function GUI:draw()
  self:displayLaunchInfo()
  self:displayHealthInfo()
  self:displayScore()
end

function GUI:displayLaunchInfo()
  for i = 1, self.player.launchRemaining do
    local x = self.launch.x + self.launch.spacing * i
    love.graphics.setColor(self.launch.color)
    love.graphics.circle("fill", x, self.launch.y, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
  end
end

function GUI:displayHealthInfo()
  for i = 1, self.player.health.current do
    local x = self.health.x + self.health.spacing * i
    love.graphics.setColor(self.health.color)
    love.graphics.circle("fill", x, self.health.y, 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
  end
end

function GUI:displayScore()
  love.graphics.print("Score: " .. math.floor(self.displayedScore), 10, 16)
end

function GUI:updateScore(dt)
  self.targetScore = self.player.coins

  if self.displayedScore < self.targetScore then
    self.displayedScore = math.min(self.displayedScore + self.scoreIncreaseSpeed * dt, self.targetScore)
  end
end

return GUI
