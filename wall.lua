local Wall = {}
local walls = {}

function Wall.new(x, y, width, height)
  local instance = {}
  instance.x = x
  instance.y = y
  instance.width = width
  instance.height = height
  instance.physics = {}
  instance.physics.body = love.physics.newBody(World, x + width / 2, y + height / 2, "static")
  instance.physics.shape = love.physics.newRectangleShape(width, height)
  instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
  instance.physics.fixture:setUserData({ type = "wall", instance = instance })
  table.insert(walls, instance)
end

function Wall.updateAll(dt)
  -- No update logic needed for static walls
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

  if other == Player then
    local nx, ny = collision:getNormal()
    if nx ~= 0 then -- Collision from the side
      Player:startClimbing()
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

  if other == Player then
    Player:stopClimbing()
    return true
  end

  return false
end

function Wall.drawAll()
  love.graphics.setColor(0.5, 0.5, 0.5)
  for _, wall in ipairs(walls) do
    love.graphics.rectangle("fill", wall.x, wall.y, wall.width, wall.height)
  end
  love.graphics.setColor(1, 1, 1)
end

return Wall
