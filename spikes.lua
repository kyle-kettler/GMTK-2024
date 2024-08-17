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
  self.damage = 1
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

  local function handleCollision(obj1, obj2)
    if obj1 and obj1.type == "spike" and obj2 and obj2.type == "player" then
      obj2.instance:takeDamage(obj1.instance.damage)
      return true
    end
    return false
  end

  local result = handleCollision(objA, objB) or handleCollision(objB, objA)

  return result
end

return Spike
