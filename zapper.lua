local middleclass = require("lib/middleclass")
local anim8 = require("lib/anim8")

local Zapper = middleclass("Zapper")

Zapper.static.spriteSheet = love.graphics.newImage("assets/sprites/zapper.png")
Zapper.static.width = 32
Zapper.static.height = 32
Zapper.static.ActiveZappers = {}

function Zapper:initialize(x1, y1, x2, y2, direction, world)
  self.startX, self.startY = x1, y1
  self.endX, self.endY = x2, y2
  self.x, self.y = x1, y1
  self.direction = direction
  self.damage = 1
  self.moveSpeed = 90
  self.movingForward = true

  -- Set rotation based on direction
  if self.direction == "up" then
    self.rotation = 0
  elseif self.direction == "right" then
    self.rotation = math.pi / 2
  elseif self.direction == "down" then
    self.rotation = math.pi
  elseif self.direction == "left" then
    self.rotation = 3 * math.pi / 2
  end

  self.physics = {}
  local colliderWidth = Zapper.width - 6
  local colliderHeight = Zapper.height / 2

  -- Adjust offset based on direction
  local offsetX = 0
  local offsetY = 0
  if self.direction == "left" or self.direction == "right" then
    offsetX = 0
    offsetY = -colliderHeight / 2
  else
    offsetX = colliderWidth / 2
    offsetY = 0
  end

  self.grid = anim8.newGrid(32, 32, Zapper.spriteSheet:getWidth(), Zapper.spriteSheet:getHeight())
  self.animation = anim8.newAnimation(self.grid("1-4", 1), 0.15)

  self.physics.body = love.physics.newBody(world, self.x + offsetX, self.y + offsetY, "kinematic")
  self.physics.body:setAngle(self.rotation)
  self.physics.shape = love.physics.newRectangleShape(0, 0, colliderWidth, colliderHeight)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
  self.physics.fixture:setSensor(true)
  self.physics.fixture:setUserData({ type = "zapper", instance = self })

  table.insert(Zapper.ActiveZappers, self)
end

function Zapper:draw()
  if self.physics.body then
    local x, y = self.physics.body:getPosition()
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(self.rotation)
    self.animation:draw(Zapper.spriteSheet, 0, -Zapper.height * 0.4, 0, 1, 1, Zapper.width / 2, 0)
    love.graphics.pop()
  end
end

function Zapper.drawAll()
  for _, instance in ipairs(Zapper.ActiveZappers) do
    instance:draw()
  end
end

function Zapper:update(dt)
  self.animation:update(dt)
  self:move(dt)
end

function Zapper:move(dt)
  local dx = self.endX - self.startX
  local dy = self.endY - self.startY
  local distance = math.sqrt(dx ^ 2 + dy ^ 2)
  local directionX = dx / distance
  local directionY = dy / distance

  local moveDistance = self.moveSpeed * dt
  if self.movingForward then
    self.x = self.x + directionX * moveDistance
    self.y = self.y + directionY * moveDistance
    if math.abs(self.x - self.endX) < 1 and math.abs(self.y - self.endY) < 1 then
      self.movingForward = false
    end
  else
    self.x = self.x - directionX * moveDistance
    self.y = self.y - directionY * moveDistance
    if math.abs(self.x - self.startX) < 1 and math.abs(self.y - self.startY) < 1 then
      self.movingForward = true
    end
  end

  self.physics.body:setPosition(self.x, self.y)
end

function Zapper.updateAll(dt)
  for _, instance in ipairs(Zapper.ActiveZappers) do
    instance:update(dt)
  end
end

function Zapper.beginContact(a, b, collision)
  local objA = a:getUserData()
  local objB = b:getUserData()

  if objA.type == "zapper" and objB.type == "player" then
    local zapperInstance = objA.instance
    local playerInstance = objB.instance
    local zapperX, zapper
    Y = zapperInstance.physics.body:getPosition()
    playerInstance:takeDamage(zapperInstance.damage)
    return true
  end
  return false
end

function Zapper.removeAll()
  for i = #Zapper.ActiveZappers, 1, -1 do
    Zapper.ActiveZappers[i]:destroy()
    table.remove(Zapper.ActiveZappers, i)
  end
end

function Zapper:destroy()
  if self.body then
    self.body:destroy()
    self.body = nil
  end
end

function Zapper.createFromTiledObject(object, world)
  local x1, y1, x2, y2, direction

  direction = object.properties.direction or "up"

  if direction == "left" or direction == "right" then
    -- Vertical track
    x1 = object.x + object.width / 2
    y1 = object.y
    x2 = x1
    y2 = object.y + object.height
  else
    -- Horizontal track
    x1 = object.x
    y1 = object.y + object.height / 2
    x2 = object.x + object.width
    y2 = y1
  end

  -- Ensure the zapper moves from left to right or top to bottom
  if (x2 < x1) or (y2 < y1) then
    x1, x2 = x2, x1
    y1, y2 = y2, y1
  end

  return Zapper:new(x1, y1, x2, y2, direction, world)
end

function Zapper.createAllFromTiledData(tiledData, world)
  local zappers = {}
  if tiledData.type == "objectgroup" and tiledData.name == "zappers" then
    for _, object in ipairs(tiledData.objects) do
      table.insert(zappers, Zapper.createFromTiledObject(object, world))
    end
  end
  return zappers
end

function Zapper:drawDebug()
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

function Zapper.drawAllDebug()
  for _, instance in ipairs(Zapper.ActiveZappers) do
    instance:drawDebug()
  end
end

return Zapper
