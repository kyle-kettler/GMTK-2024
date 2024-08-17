local Constants = require("constants")
local Player = require("player")

local BFL = {}

function BFL:load()
  self.width = Constants.MAP_PIXEL_WIDTH     -- Full width of the screen
  self.height = 40                           -- Thickness of the laser
  self.y = Constants.MAP_BOTTOM + self.height -- Start below the bottom of the screen
  self.color = { 1, 0, 0, 0.7 }              -- Red color with some transparency
  self.damage = 999                          -- High damage for a big laser
  self.active = false                        -- Laser starts inactive
  self.warmupTime = 0                        -- Time in seconds before the laser activates
  self.warmupTimer = 0
  self.speed = 10                            -- Speed of upward movement (adjust as needed)
  self.damageCooldown = 0.1                  -- Time between damage ticks
  self.damageTimer = 0                       -- Timer to track cooldown

  self.physics = {}
  -- Position the body at the top of the laser
  self.physics.body = love.physics.newBody(World, Constants.MAP_PIXEL_WIDTH / 2, self.y, "kinematic")
  self.physics.shape = love.physics.newRectangleShape(0, self.height / 2, self.width, self.height)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
  self.physics.fixture:setSensor(true)
  self.physics.fixture:setUserData("BFL")
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

    -- Check for overlap with player and apply damage
    self:checkPlayerOverlap(dt)

    -- Reset the laser if it goes off the top of the screen
    if self.y + self.height < 0 then
      self:reset()
    end
  end

  -- Update damage cooldown timer
  self.damageTimer = math.max(0, self.damageTimer - dt)
end

function BFL:checkPlayerOverlap(dt)
  if not self.active then
    return
  end

  local x1, y1, x2, y2 = self.physics.fixture:getBoundingBox()
  local px1, py1, px2, py2 = Player.physics.fixture:getBoundingBox()

  if x1 < px2 and x2 > px1 and y1 < py2 and y2 > py1 then
    -- Overlap detected
    if self.damageTimer <= 0 then
      Player:takeDamage(self.damage)
      self.damageTimer = self.damageCooldown
    end
  end
end

function BFL:draw()
  if not self.active then
    -- Draw warning rectangle at the bottom of the screen
    love.graphics.setColor(1, 0, 0, 0.5) -- Red with transparency
    love.graphics.rectangle("fill", 0, Constants.MAP_BOTTOM - 10, self.width, 10)
  else
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

return BFL
