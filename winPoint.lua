local middleclass = require("lib/middleclass")
local Win = middleclass("Win")

function Win:initialize(world, x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.physics = {}
  self.physics.body = love.physics.newBody(world, x + width / 2, y + height / 2, "static")
  self.physics.shape = love.physics.newRectangleShape(width, height)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
  self.physics.fixture:setUserData({ type = "win", instance = self })
  self.physics.fixture:setSensor(true)
end

function Win:checkPlayerWin(player)
  if not player or not player.physics or not player.physics.body then
    return false
  end

  local px, py = player.physics.body:getPosition()

  return px >= self.x and px <= self.x + self.width and py >= self.y and py <= self.y + self.height
end

function Win:update(dt)
end

function Win:draw()
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
