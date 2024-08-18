local middleclass = require("lib/middleclass")
local Wall = middleclass("Wall")

function Wall:initialize(world, x, y, width, height)
  self.x = x
  self.y = y
  self.width = width
  self.height = height
  self.physics = {}
  self.physics.body = love.physics.newBody(world, x + width / 2, y + height / 2, "static")
  self.physics.shape = love.physics.newRectangleShape(width, height)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
  self.physics.fixture:setUserData({ type = "wall", instance = self })
end

function Wall:update(dt)
  -- No update logic needed for static walls
end

function Wall:draw()
  -- You might want to add drawing logic here if you want to visualize the walls
end

function Wall.beginContact(a, b, collision)
  local objA = a:getUserData()
  local objB = b:getUserData()
  local wall, other
  if objA and objA.type == "wall" then
    wall = objA.instance
    other = objB
  elseif objB and objB.type == "wall" then
    wall = objB.instance
    other = objA
  else
    return false
  end
  if other and other.type == "player" then
    local nx, ny = collision:getNormal()
    if nx ~= 0 then -- Collision from the side
      other.instance:startClimbing()
    end
    return true
  end
  return false
end

function Wall.endContact(a, b, collision)
  local objA = a:getUserData()
  local objB = b:getUserData()
  local wall, other
  if objA and objA.type == "wall" then
    wall = objA.instance
    other = objB
  elseif objB and objB.type == "wall" then
    wall = objB.instance
    other = objA
  else
    return false
  end
  if other and other.type == "player" then
    other.instance:stopClimbing()
    return true
  end
  return false
end

return Wall
