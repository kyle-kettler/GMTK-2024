local middleclass = require("lib/middleclass")
local Player = require("player") -- Make sure this path is correct

local Spike = middleclass("Spike")

Spike.static.img = love.graphics.newImage("assets/sprites/spikes.png")
Spike.static.width = Spike.static.img:getWidth()
Spike.static.height = Spike.static.img:getHeight()

Spike.static.ActiveSpikes = {}

function Spike:initialize(x, y, world)
  self.x = x
  self.y = y
  self.damage = 2
  self.physics = {}
  self.physics.body = love.physics.newBody(world, self.x, self.y, "static")
  self.physics.shape = love.physics.newRectangleShape(Spike.width - 4, Spike.height - 2)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
  self.physics.fixture:setSensor(true)
  self.physics.fixture:setUserData({ type = "spike", instance = self })
  table.insert(Spike.ActiveSpikes, self)
end

function Spike:draw()
  love.graphics.draw(Spike.img, self.x, self.y, 0, 1, 1, Spike.width / 2, Spike.height / 2)
end

function Spike.drawAll()
  for _, instance in ipairs(Spike.ActiveSpikes) do
    instance:draw()
  end
end

function Spike:update(dt)
  -- Update logic if needed
end

function Spike.updateAll(dt)
  for _, instance in ipairs(Spike.ActiveSpikes) do
    instance:update(dt)
  end
end

function Spike.beginContact(a, b, collision)
  local objA = a:getUserData()
  local objB = b:getUserData()

  if objA.type == "spike" and objB.type == "player" then
    objB.instance:takeDamage(objA.instance.damage)
    return true
  elseif objB.type == "spike" and objA.type == "player" then
    objA.instance:takeDamage(objB.instance.damage)
    return true
  end

  return false
end

function Spike.removeAll()
  for i = #Spike.ActiveSpikes, 1, -1 do
    Spike.ActiveSpikes[i]:destroy()
    table.remove(Spike.ActiveSpikes, i)
  end
end

function Spike:destroy()
  if self.body then
    self.body:destroy()
    self.body = nil
  end
end

return Spike
