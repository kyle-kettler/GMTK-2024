local middleclass = require("lib/middleclass")
local anim8 = require("lib/anim8")

local Spike = middleclass("Spike")

Spike.static.spriteSheet = love.graphics.newImage("assets/sprites/spikes.png")
Spike.static.width = 32
Spike.static.height = 32

Spike.static.ActiveSpikes = {}

function Spike:initialize(x, y, rotation, world)
  self.x = x
  self.y = y
  self.rotation = rotation
  self.damage = 1
  self.physics = {}

  local colliderWidth = Spike.width - 6
  local colliderHeight = Spike.height / 2
  local offsetX = math.sin(self.rotation) * (Spike.height / 4 - colliderHeight)
  local offsetY = -math.cos(self.rotation) * (Spike.height / 4 - colliderHeight)

  self.grid = anim8.newGrid(32, 32, Spike.spriteSheet:getWidth(), Spike.spriteSheet:getHeight())
  self.animation = anim8.newAnimation(self.grid("1-4", 1), 0.15)

  self.physics.body = love.physics.newBody(world, self.x + offsetX, self.y + offsetY, "static")
  self.physics.body:setAngle(self.rotation)

  self.physics.shape = love.physics.newRectangleShape(0, 0, colliderWidth, colliderHeight)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
  self.physics.fixture:setSensor(true)
  self.physics.fixture:setUserData({ type = "spike", instance = self })

  table.insert(Spike.ActiveSpikes, self)
end

function Spike:draw()
  if self.physics.body then
    local x, y = self.physics.body:getPosition()
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(self.rotation)
    self.animation:draw(Spike.spriteSheet, 0, -Spike.height * 0.4, 0, 1, 1, Spike.width/2, 0)
    love.graphics.pop()
  end
end

function Spike.drawAll()
  for _, instance in ipairs(Spike.ActiveSpikes) do
    instance:draw()
  end
end

function Spike:update(dt)
  self.animation:update(dt)
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
    local spikeInstance = objA.instance
    local playerInstance = objB.instance
    local spikeX, spikeY = spikeInstance.physics.body:getPosition()
    playerInstance:takeDamage(spikeInstance.damage)
    return true
    -- elseif objB.type == "spike" and objA.type == "player" then
    --   local spikeInstance = objB.instance
    --   local playerInstance = objA.instance
    --   local spikeX, spikeY = spikeInstance.physics.body:getPosition()
    --   playerInstance:takeDamage(spikeInstance.damage, spikeX, spikeY)
    --   return true
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

function Spike:drawDebug()
  love.graphics.push("all")

  -- Draw body
  love.graphics.setColor(0, 1, 0, 0.5) -- Green for body
  love.graphics.circle("fill", self.physics.body:getX(), self.physics.body:getY(), 5)
  love.graphics.print("Body", self.physics.body:getX() + 10, self.physics.body:getY() - 10)

  -- Draw fixture/shape
  love.graphics.setColor(1, 0, 0, 0.5) -- Red for fixture/shape
  local points = { self.physics.body:getWorldPoints(self.physics.shape:getPoints()) }
  love.graphics.polygon("line", points)
  love.graphics.print("Fixture", points[1], points[2] - 20)

  -- Draw sensor area
  love.graphics.setColor(0, 0, 1, 0.3) -- Blue for sensor area
  love.graphics.polygon("fill", points)
  love.graphics.print("Sensor", points[1], points[2] + 20)

  love.graphics.pop()
end

function Spike.drawAllDebug()
  for _, instance in ipairs(Spike.ActiveSpikes) do
    instance:drawDebug()
  end
end

return Spike
