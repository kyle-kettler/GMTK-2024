local middleclass = require("lib/middleclass")
local anim8 = require("lib/anim8")
local Player = require("player")

local Bolt = middleclass("Bolt")

Bolt.static.spriteSheet = love.graphics.newImage("assets/sprites/gem_and_bolt.png")
Bolt.static.width = 11
Bolt.static.height = 11
Bolt.static.ActiveBolts = {}
Bolt.static.collectedCount = 0

function Bolt:initialize(x, y, world)
  self.x = x
  self.y = y
  self.scale = 0.8
  self.randomTimeOffset = math.random(0, 100)
  self.toBeRemoved = false
  self.grid = anim8.newGrid(32, 32, Bolt.spriteSheet:getWidth(), Bolt.spriteSheet:getHeight())
  self.animation = anim8.newAnimation(self.grid("1-3", 2), 0.15)
  self.physics = {}
  self.physics.body = love.physics.newBody(world, self.x, self.y, "dynamic")
  self.physics.shape = love.physics.newRectangleShape(Bolt.width, Bolt.height)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
  self.physics.fixture:setSensor(true)
  self.physics.fixture:setUserData({ type = "bolt", instance = self })
  table.insert(Bolt.ActiveBolts, self)
end

function Bolt:update(dt)
  if not self.physics.body then
    self:remove()
    return
  end

  self.animation:update(dt)
  self:checkRemove()
end

function Bolt:remove()
  for i, instance in ipairs(Bolt.ActiveBolts) do
    if instance == self then
      Bolt.collectedCount = Bolt.collectedCount + 1
      if self.physics.body then
        self.physics.body:destroy()
        self.physics.body = nil
      end
      table.remove(Bolt.ActiveBolts, i)
      break
    end
  end
end

function Bolt:checkRemove()
  if self.toBeRemoved then
    self:remove()
  end
end

function Bolt.updateAll(dt)
  for i = #Bolt.ActiveBolts, 1, -1 do
    local instance = Bolt.ActiveBolts[i]
    instance:update(dt)
  end
end

function Bolt:draw()
  if self.physics.body then
    local x, y = self.physics.body:getPosition()
    self.animation:draw(Bolt.spriteSheet, x, y, 0, self.scale, self.scale, 11, 11)
  end
end

function Bolt.drawAll()
  for _, instance in ipairs(Bolt.ActiveBolts) do
    instance:draw()
  end
end

function Bolt.beginContact(a, b, collision)
  local objA = a:getUserData()
  local objB = b:getUserData()
  local function handleCollision(obj1, obj2)
    if obj1 and obj1.type == "bolt" and obj2 and obj2.type == "player" then
      obj1.instance.toBeRemoved = true
      obj2.instance:addHealth()
      return true
    end
    return false
  end
  local result = handleCollision(objA, objB) or handleCollision(objB, objA)
  return result
end

function Bolt.removeAll()
  for i = #Bolt.ActiveBolts, 1, -1 do
    Bolt.ActiveBolts[i]:destroy()
    table.remove(Bolt.ActiveBolts, i)
  end
end

function Bolt:destroy()
  if self.body then
    self.body:destroy()
    self.body = nil
  end
end

return Bolt
