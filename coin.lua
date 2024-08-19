local middleclass = require("lib/middleclass")
local anim8 = require("lib/anim8")
local Player = require("player")

local Coin = middleclass("Coin")

Coin.static.spriteSheet = love.graphics.newImage("assets/sprites/gem_and_bolt.png")
Coin.static.width = 11
Coin.static.height = 11
Coin.static.ActiveCoins = {}
Coin.static.collectedCount = 0
Coin.static.attractionRadius = 50
Coin.static.attractionSpeed = 200
Coin.static.minDistance = 1
Coin.static.pointValues = {
  gem = 10,
  diamond = 50
}

function Coin:initialize(x, y, world, gemType)
  self.type = gemType
  self.x = x
  self.y = y
  self.scaleX = 1
  self.randomTimeOffset = math.random(0, 100)
  self.toBeRemoved = false
  self.isAttracting = false -- New flag to track if the coin is attracting
  self.grid = anim8.newGrid(32, 32, Coin.spriteSheet:getWidth(), Coin.spriteSheet:getHeight())
  self.animations = {}
  self.animations.gem = anim8.newAnimation(self.grid("1-3", 1), 0.15)
  self.animations.diamond = anim8.newAnimation(self.grid("1-4", 3), 0.15)
  self.currentAnimation = self.animations[self.type]
  self.physics = {}
  self.physics.body = love.physics.newBody(world, self.x, self.y, "dynamic")
  self.physics.shape = love.physics.newRectangleShape(Coin.width, Coin.height)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
  self.physics.fixture:setSensor(true)
  self.physics.fixture:setUserData({ type = "coin", instance = self })
  table.insert(Coin.ActiveCoins, self)
end

function Coin:update(dt)
  if not self.physics.body then
    self:remove()
    return
  end

  if self.currentAnimation then
    self.currentAnimation:update(dt)
  end

  self:checkPlayerProximity()
  if self.isAttracting then
    self:attractToPlayer(dt)
  end
  self:checkRemove()
end

function Coin:checkPlayerProximity()
  local player = Player.instance
  if player then
    local px, py = player:getPosition()
    local cx, cy = self.physics.body:getPosition()
    local dx = px - cx
    local dy = py - cy
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance <= Coin.attractionRadius then
      self.isAttracting = true
    end
  end
end

function Coin:attractToPlayer(dt)
  if not self.physics.body then
    return
  end

  local player = Player.instance
  if player then
    local px, py = player:getPosition()
    local cx, cy = self.physics.body:getPosition()
    local dx = px - cx
    local dy = py - cy
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > Coin.minDistance then
      local angle = math.atan2(dy, dx)
      local fx = math.cos(angle) * Coin.attractionSpeed
      local fy = math.sin(angle) * Coin.attractionSpeed
      self.physics.body:setLinearVelocity(fx, fy)
    else
      self.physics.body:setLinearVelocity(0, 0)
    end
  end
end

function Coin:remove()
  for i, instance in ipairs(Coin.ActiveCoins) do
    if instance == self then
      Coin.collectedCount = Coin.collectedCount + 1
      local pointValue = Coin.pointValues[self.type] or 0
      print("Coins collected:", Coin.collectedCount, "Points:", pointValue)
      if self.physics.body then
        self.physics.body:destroy()
        self.physics.body = nil
      end
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

function Coin.updateAll(dt)
  for i = #Coin.ActiveCoins, 1, -1 do
    local instance = Coin.ActiveCoins[i]
    instance:update(dt)
  end
end

function Coin:draw()
  if self.physics.body then
    local x, y = self.physics.body:getPosition()
    if self.currentAnimation then
      self.currentAnimation:draw(Coin.spriteSheet, x, y, 0, self.scaleX, 1, 11, 11)
    end
  end
end

function Coin.drawAll()
  for _, instance in ipairs(Coin.ActiveCoins) do
    instance:draw()
  end
end

function Coin.beginContact(a, b, collision)
  local objA = a:getUserData()
  local objB = b:getUserData()
  local function handleCollision(obj1, obj2)
    if obj1 and obj1.type == "coin" and obj2 and obj2.type == "player" then
      obj1.instance.toBeRemoved = true
      local pointValue = Coin.pointValues[obj1.instance.type] or 0
      obj2.instance:incrementCoins(pointValue)
      return true
    end
    return false
  end
  local result = handleCollision(objA, objB) or handleCollision(objB, objA)
  return result
end

function Coin.removeAll()
  for i = #Coin.ActiveCoins, 1, -1 do
function Coin:draw()
  if self.physics.body then
    local x, y = self.physics.body:getPosition()
    if self.type == "gem" then
      self.animations.gem:draw(Coin.spriteSheet, x, y, 0, self.scaleX, 1, 11, 11)
    end
    if self.type == "diamond" then
      self.animations.diamond:draw(Coin.spriteSheet, x, y, 0, self.scaleX, 1, 11, 11)
    end
  end
end
    Coin.ActiveCoins[i]:destroy()
    table.remove(Coin.ActiveCoins, i)
  end
end

function Coin:destroy()
  if self.body then
    self.body:destroy()
    self.body = nil
  end
end

return Coin
