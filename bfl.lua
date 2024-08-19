local middleclass = require("lib/middleclass")
local Constants = require("constants")

local BFL = middleclass("BFL")

function BFL:initialize(world)
  self.width = Constants.MAP_PIXEL_WIDTH
  self.height = 40
  self.y = Constants.MAP_BOTTOM + self.height
  self.color = { 1, 0, 0, 0.7 }
  self.damage = 999
  self.active = false
  self.warmupTime = 0
  self.warmupTimer = 0
  self.speed = 60
  self.damageCooldown = 0.1
  self.damageTimer = 0

  self.physics = {}
  self.physics.body = love.physics.newBody(world, Constants.MAP_PIXEL_WIDTH / 2, self.y, "kinematic")
  self.physics.shape = love.physics.newRectangleShape(0, self.height / 2, self.width, self.height)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
  self.physics.fixture:setSensor(true)
  self.physics.fixture:setUserData({ type = "bfl", instance = self })

  self.world = world
end

function BFL:update(dt)
  if not self.active then
    self.warmupTimer = self.warmupTimer + dt
    if self.warmupTimer >= self.warmupTime then
      self.active = true
    end
  else
    -- Move the laser upward
    self.y = self.y - self.speed * dt
    -- Update the physics body position to match the top of the laser
    self.physics.body:setY(self.y)
    -- Reset the laser if it goes off the top of the screen
    if self.y + self.height < 0 then
      self:reset()
    end

    -- Check for continuous contact with the player
    self:checkPlayerContact()
  end
  -- Update damage cooldown timer
  self.damageTimer = math.max(0, self.damageTimer - dt)
end

function BFL:draw()
  if self.active then
    -- Draw active laser
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", 0, self.y, self.width, self.height)
    -- Draw additional laser effects
    love.graphics.setColor(1, 1, 1, 0.5) -- White with transparency
    for i = 1, 5 do
      love.graphics.line(0, self.y + i, self.width, self.y + i)
      love.graphics.line(0, self.y + self.height - i, self.width, self.y + self.height - i)
    end
  end
  love.graphics.setColor(1, 1, 1) -- Reset color to white
end

function BFL:reset()
  self.y = Constants.MAP_BOTTOM + self.height
  self.physics.body:setY(self.y)
  self.active = false
  self.warmupTimer = 0
  self.damageTimer = 0
end

function BFL:checkPlayerContact()
  if self.active and self.damageTimer <= 0 then
    local contacts = self.physics.body:getContacts()
    for _, contact in ipairs(contacts) do
      local fixtureA, fixtureB = contact:getFixtures()
      local objA = fixtureA:getUserData()
      local objB = fixtureB:getUserData()
      
      local player = (objA and objA.type == "player" and objA.instance) or
                     (objB and objB.type == "player" and objB.instance)
      
      if player then
        player:takeDamage(self.damage)
        self.damageTimer = self.damageCooldown
        break
      end
    end
  end
end

local function checkCollision(a, b)
  local objA = a:getUserData()
  local objB = b:getUserData()

  local function handleCollision(bfl, player)
    if bfl and bfl.type == "bfl" and player and player.type == "player" then
      if bfl.instance.active and bfl.instance.damageTimer <= 0 then
        player.instance:takeDamage(bfl.instance.damage)
        bfl.instance.damageTimer = bfl.instance.damageCooldown
        return true
      end
    end
    return false
  end

  return handleCollision(objA, objB) or handleCollision(objB, objA)
end

function BFL.beginContact(a, b, collision)
  return checkCollision(a, b)
end

function BFL.preSolve(a, b, collision)
  return checkCollision(a, b)
end

return BFL
