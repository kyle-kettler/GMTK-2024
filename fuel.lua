local middleclass = require("lib/middleclass")
local anim8 = require("lib/anim8")
local Player = require("player")

local Fuel = middleclass("Fuel")

Fuel.static.spriteSheet = love.graphics.newImage("assets/sprites/fuel.png")
Fuel.static.width = 11
Fuel.static.height = 11
Fuel.static.ActiveFuel = {}
Fuel.static.collectedCount = 0
Fuel.static.respawnTime = 8
Fuel.static.removedFuel = {}

Fuel.static.world = nil -- Store the world object statically

function Fuel.static.setWorld(world)
  Fuel.world = world
end

function Fuel:initialize(x, y)
  if not Fuel.world then
    error("Fuel.world is not set. Call Fuel.setWorld(world) before creating Fuel objects.")
  end
  self.x = x
  self.y = y
  self.scale = 0.8
  self.randomTimeOffset = math.random(0, 100)
  self.toBeRemoved = false
  self.grid = anim8.newGrid(32, 32, Fuel.spriteSheet:getWidth(), Fuel.spriteSheet:getHeight())
  self.animation = anim8.newAnimation(self.grid("1-4", 1), 0.15)

  self.physics = {}
  self.physics.body = love.physics.newBody(Fuel.world, self.x, self.y, "dynamic")
  self.physics.shape = love.physics.newRectangleShape(Fuel.width, Fuel.height)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
  self.physics.fixture:setSensor(true)
  self.physics.fixture:setUserData({ type = "fuel", instance = self })
  table.insert(Fuel.ActiveFuel, self)
end

function Fuel:update(dt)
  if not self.physics.body then
    self:remove()
    return
  end

  if self.animation then
    self.animation:update(dt)
  end

  self:checkRemove()
end

function Fuel:remove()
  for i, instance in ipairs(Fuel.ActiveFuel) do
    if instance == self then
      Fuel.collectedCount = Fuel.collectedCount + 1
      if self.physics.body then
        self.physics.body:destroy()
        self.physics.body = nil
      end
      table.remove(Fuel.ActiveFuel, i)

      table.insert(Fuel.removedFuel, { x = self.x, y = self.y, removedTime = love.timer.getTime() })
      break
    end
  end
end

function Fuel:checkRemove()
  if self.toBeRemoved then
    self:remove()
  end
end

function Fuel.updateAll(dt)
  for i = #Fuel.ActiveFuel, 1, -1 do
    local instance = Fuel.ActiveFuel[i]
    instance:update(dt)
  end

  local currentTime = love.timer.getTime()
  for i = #Fuel.removedFuel, 1, -1 do
    local removedFuel = Fuel.removedFuel[i]
    if currentTime - removedFuel.removedTime >= Fuel.respawnTime then
      Fuel:new(removedFuel.x, removedFuel.y, removedFuel.world)
      table.remove(Fuel.removedFuel, i)
    end
  end
end

function Fuel:draw()
  if self.physics.body then
    local x, y = self.physics.body:getPosition()
    self.animation:draw(Fuel.spriteSheet, x, y, 0, self.scale, self.scale, 32, 24)
  end
end

function Fuel.drawAll()
  for _, instance in ipairs(Fuel.ActiveFuel) do
    instance:draw()
  end
end

function Fuel.beginContact(a, b, collision)
  local objA = a:getUserData()
  local objB = b:getUserData()
  local function handleCollision(obj1, obj2)
    if obj1 and obj1.type == "fuel" and obj2 and obj2.type == "player" then
      obj1.instance.toBeRemoved = true
      obj2.instance:addFuel(1)
      return true
    end
    return false
  end
  local result = handleCollision(objA, objB) or handleCollision(objB, objA)
  return result
end

function Fuel.removeAll()
  for i = #Fuel.ActiveFuel, 1, -1 do
    Fuel.ActiveFuel[i]:destroy()
    table.remove(Fuel.ActiveFuel, i)
  end
end

function Fuel:destroy()
  if self.body then
    self.body:destroy()
    self.body = nil
  end
end

return Fuel
