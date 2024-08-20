local middleclass = require("lib/middleclass")
local Constants = require("constants")

local GUI = middleclass("GUI")

function GUI:initialize(player)
  self.player = player
  self:load()
end

function GUI:load()
  self.fuel = {}
  self.fuel.x = -8
  self.fuel.y = Constants.GAME_HEIGHT - 40
  self.fuel.img = love.graphics.newImage("assets/sprites/fuel_static.png")
  self.fuel.width = 5
  self.fuel.height = 5
  self.fuel.scale = 1
  self.fuel.spacing = self.fuel.width * self.fuel.scale + 10

  self.health = {}
  self.health.img = love.graphics.newImage("assets/sprites/bolt.png")
  self.health.x = -10
  self.health.y = 5
  self.health.width = 5
  self.health.height = 5
  self.health.scale = 1
  self.health.spacing = self.health.width * self.health.scale + 10

  self.score = 0
  self.displayedScore = 0
  self.targetScore = 0
  self.scoreIncreaseSpeed = 30
  self.gem = {}
  self.gem.img = love.graphics.newImage("assets/sprites/gem.png")
  self.gem.width = self.gem.img:getWidth()
  self.gem.height = self.gem.img:getHeight()
  self.gem.scale = 1
  self.gem.x = Constants.GAME_WIDTH - 40
  self.gem.y = 3
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
    local x = self.fuel.x + self.fuel.spacing * i
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.draw(self.fuel.img, x + 1, self.fuel.y + 2, 0, self.fuel.scale, self.fuel.scale)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.fuel.img, x, self.fuel.y, 0, self.fuel.scale, self.fuel.scale)
  end
end

function GUI:displayHealthInfo()
  for i = 1, self.player.health.current do
    local x = self.health.x + self.health.spacing * i
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.draw(self.health.img, x + 1, self.health.y + 2, 0, self.health.scale, self.health.scale)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.health.img, x, self.health.y, 0, self.health.scale, self.health.scale)
  end
end

function GUI:displayScore()
  -- Calculate new x position for the score
  local scoreX = self.gem.x  -- Adjust this value to fine-tune the position

  -- Draw the gem
  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.draw(self.gem.img, self.gem.x + 2, self.gem.y + 2, 0, self.gem.scale, self.gem.scale)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.gem.img, self.gem.x, self.gem.y, 0, self.gem.scale, self.gem.scale)

  -- Draw the score
  love.graphics.setFont(Fonts["medium"])
  local scoreText = tostring(math.floor(self.displayedScore))
  local textWidth = Fonts["medium"]:getWidth(scoreText)

  -- Align the score to the right of the calculated x position
  local textX = scoreX - textWidth

  -- Draw the score with shadow
  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.print(scoreText, textX + 2, self.gem.y + 10 + 2)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(scoreText, textX, self.gem.y + 10)

  love.graphics.setColor(1, 1, 1, 1)
end

function GUI:updateScore(dt)
  self.targetScore = self.player.coins

  if self.displayedScore < self.targetScore then
    self.displayedScore = math.min(self.displayedScore + self.scoreIncreaseSpeed * dt, self.targetScore)
  end
end

return GUI
