local middleclass = require("lib/middleclass")
local anim8 = require("lib/anim8")

local Win = middleclass("Win")

Win.static.spriteSheet = love.graphics.newImage("assets/sprites/rocket-launchpad.png")
Win.static.width = 96
Win.static.height = 96

function Win:initialize(world, x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height

  -- Physics setup
  self.physics = {}
  self.physics.body = love.physics.newBody(world, x + width / 2, y + height / 2, "static")
  self.physics.shape = love.physics.newRectangleShape(width, height)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
  self.physics.fixture:setUserData({ type = "win", instance = self })
  self.physics.fixture:setSensor(true)

  -- Animation setup
  self.grid = anim8.newGrid(96, 96, Win.spriteSheet:getWidth(), Win.spriteSheet:getHeight())
  self.animation = anim8.newAnimation(self.grid("1-3", 1), 0.2)
end

function Win:checkPlayerWin(player)
  if not player or not player.physics or not player.physics.body then
    return false
  end
  local px, py = player.physics.body:getPosition()
  return px >= self.x and px <= self.x + self.width and py >= self.y and py <= self.y + self.height
end

function Win:update(dt)
  self.animation:update(dt)
end

function Win:draw()
  if self.animation and Win.spriteSheet then
    self.animation:draw(Win.spriteSheet, self.x, self.y - 33)
  elseif Win.debug then
    -- Draw a placeholder rectangle if the sprite isn't available
    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Win Area", self.x + 5, self.y + 5)
  end

  if Win.debug then
    love.graphics.print("Win Position: " .. self.x .. ", " .. self.y, 10, 10)
  end
end

function Win.beginContact(a, b, collision)
  local objA = a:getUserData()
  local objB = b:getUserData()
  local win, other
  if objA and objA.type == "win" then
    win = objA.instance
    other = objB
  elseif objB and objB.type == "win" then
    win = objB.instance
    other = objA
  else
    return false
  end
  if other and other.type == "player" then
    return true
  end
  return false
end

function Win.endContact(a, b, collision)
  return false
end

return Win
