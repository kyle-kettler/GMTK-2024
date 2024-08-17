local middleclass = require("lib/middleclass")
local anim8 = require("lib/anim8")
local Player = require("player")

local Coin = middleclass("Coin")

Coin.static.spriteSheet = love.graphics.newImage("assets/sprites/coin.png")
Coin.static.width = 11
Coin.static.height = 11
Coin.static.ActiveCoins = {}
Coin.static.collectedCount = 0

function Coin:initialize(x, y, world)
  self.x = x
  self.y = y
  self.scaleX = 1
  self.randomTimeOffset = math.random(0, 100)
  self.toBeRemoved = false

  self.grid = anim8.newGrid(11, 11, Coin.spriteSheet:getWidth(), Coin.spriteSheet:getHeight())
  self.animation = anim8.newAnimation(self.grid("1-4", 1), 0.15)

  self.physics = {}
  self.physics.body = love.physics.newBody(world, self.x, self.y, "static")
  self.physics.shape = love.physics.newRectangleShape(Coin.width, Coin.height)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
  self.physics.fixture:setSensor(true)
  self.physics.fixture:setUserData({ type = "coin", instance = self })

  table.insert(Coin.ActiveCoins, self)
end

function Coin:draw()
  self.animation:draw(Coin.spriteSheet, self.x, self.y, 0, self.scaleX, 1, 11, 11)
end

function Coin.drawAll()
  for _, instance in ipairs(Coin.ActiveCoins) do
    instance:draw()
  end
end

function Coin:update(dt)
  self.animation:update(dt)
  self:checkRemove()
end

function Coin.updateAll(dt)
  for _, instance in ipairs(Coin.ActiveCoins) do
    instance:update(dt)
  end
end

function Coin:remove()
  for i, instance in ipairs(Coin.ActiveCoins) do
    if instance == self then
      Coin.collectedCount = Coin.collectedCount + 1 -- Increment the static counter
      print("Coins collected:", Coin.collectedCount)
      self.physics.body:destroy()
      table.remove(Coin.ActiveCoins, i)
      break
    end
  end
end

function Coin:checkRemove()
  if self.toBeRemoved then
    self:remove()
  end
end

function Coin.beginContact(a, b, collision)
  local objA = a:getUserData()
  local objB = b:getUserData()
  local function handleCollision(obj1, obj2)
    if obj1 and obj1.type == "coin" and obj2 and obj2.type == "player" then
      obj1.instance.toBeRemoved = true
      obj2.instance:incrementCoins()
      return true
    end
    return false
  end
  local result = handleCollision(objA, objB) or handleCollision(objB, objA)
  return result
end

return Coin
