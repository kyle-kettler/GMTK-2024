local anim8 = require("lib/anim8")
Constants = require("constants")

local Player = {}

function Player:load()
  -- Basic properties
  self.x = 100
  self.y = Constants.MAP_BOTTOM - 150
  self.startX = self.x
  self.startY = self.y
  self.width = 24
  self.height = 30
  self.direction = 1
  self.xVel = 0
  self.yVel = 0
  self.maxSpeed = 300
  self.acceleration = 4000
  self.friction = 4000
  self.gravity = 1700
  self.jumpAmount = -650
  self.isMoving = false

  -- Health and state
  self.isAlive = true
  self.health = { current = 3, max = 3 }

  -- Visual properties
  self.color = { red = 1, green = 1, blue = 1, speed = 5 }

  -- Game mechanics
  self.coins = 0
  self.grounded = false
  self.hasDoubleJump = true
  self.graceTime = 0
  self.graceDuration = 0.1

  -- Dash properties
  self.isDashing = false
  self.dashDuration = 0.1
  self.dashSpeed = 800
  self.dashCooldown = 0.5
  self.dashTimer = 0
  self.dashCooldownTimer = 0
  self.isAirDashing = false
  self.upwardDashMultiplier = 0.4

  -- Wall climbing properties
  self.isClimbing = false
  self.climbSpeed = 200
  self.wallJumpForce = { x = 300, y = -500 }
  self.wallSlideSpeed = 50
  self.wallStickTime = 0.2
  self.wallStickTimer = 0
  self.maxClimbTime = 1
  self.climbTimer = 0

  self.state = "idle"

  -- Physics setup
  self.physics = {}
  self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
  self.physics.body:setFixedRotation(true)
  self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
  self.physics.fixture:setUserData(self)

  -- Wall sensor
  self.wallSensor = {}
  self.wallSensor.shape = love.physics.newRectangleShape(self.width + 4, self.height)
  self.wallSensor.fixture = love.physics.newFixture(self.physics.body, self.wallSensor.shape, 1)
  self.wallSensor.fixture:setSensor(true)

  -- Animation setup
  self.spriteSheet = love.graphics.newImage("assets/sprites/player.png")
  self.grid = anim8.newGrid(32, 32, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

  self.animations = {
    idle = anim8.newAnimation(self.grid("1-5", 1), 0.12),
    run = anim8.newAnimation(self.grid("1-6", 2), 0.1),
    jump = anim8.newAnimation(self.grid("1-3", 3), 0.1, "pauseAtEnd"),
    fall = anim8.newAnimation(self.grid("1-1", 4), 0.1, "pauseAtEnd"),
    climb = anim8.newAnimation(self.grid("1-2", 5), 0.2),
  }
  self.anim = self.animations.idle
end

function Player:update(dt)
  self:unTint(dt)
  self:respawn()
  self:setState()
  self:syncPhysics()
  self.anim:update(dt)
  self:move(dt)
  self:applyGravity(dt)
  self:decreaseGraceTime(dt)
  self:updateDash(dt)
  self:updateWallClimb(dt)
  if self.isClimbing then
    self.yVel = self.yInput * self.climbSpeed
  end
end

function Player:setState()
  if self.isClimbing then
    self.state = "climb"
    self.anim = self.animations.climb
  elseif self.isDashing then
    self.state = "dash"
  elseif self.yVel < 0 then
    self.state = "jump"
    self.anim = self.animations.jump
  elseif self.yVel > 0 then
    self.state = "fall"
    self.anim = self.animations.fall
  elseif self.xVel == 0 then
    self.state = "idle"
    self.anim = self.animations.idle
  else
    self.state = "run"
    self.anim = self.animations.run
  end
end

function Player:takeDamage(amount)
  self:damageFlash()
  if self.health.current > 0 then
    self.health.current = self.health.current - amount
  else
    self.health.current = 0
    self:die()
  end
end

function Player:respawn()
  if not self.isAlive then
    self.physics.body:setPosition(self.startX, self.startY)
    self.health.current = self.health.max
    self.isAlive = true
  end
end

function Player:die()
  self.isAlive = false
end

function Player:damageFlash()
  self.color.green = 0
  self.color.blue = 0
end

function Player:unTint(dt)
  self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
  self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
  self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

function Player:incrementCoins()
  self.coins = self.coins + 1
end

function Player:move(dt, moveX, moveY)
  if not self.isDashing then
    moveX = moveX or 0
    moveY = moveY or 0
    self.isMoving = (moveX ~= 0 or moveY ~= 0)
    if self.isClimbing then
      self.yVel = moveY * self.climbSpeed
    else
      if moveX ~= 0 then
        self.direction = moveX > 0 and 1 or -1
        self.xVel = moveX * self.maxSpeed
      else
        self:applyFriction(dt)
      end
    end
    self.yInput = moveY
  end
end

function Player:updateWallClimb(dt)
  if self.isClimbing then
    self.yVel = math.min(self.yVel, self.wallSlideSpeed)
    self.wallStickTimer = self.wallStickTime

    -- Update climb timer
    self.climbTimer = self.climbTimer + dt
    if self.climbTimer >= self.maxClimbTime then
      self:stopClimbing()
    end
  elseif self.wallStickTimer > 0 then
    self.wallStickTimer = self.wallStickTimer - dt
    if self.wallStickTimer <= 0 then
      self:stopClimbing()
    end
  end
end

function Player:startClimbing()
  self.isClimbing = true
  self.climbTimer = 0
end

function Player:stopClimbing()
  self.isClimbing = false
end

function Player:jump()
  self.isMoving = true
  if self.grounded or self.graceTime > 0 then
    self.yVel = self.jumpAmount
    self.grounded = false
    self.graceTime = 0
  elseif self.isClimbing then
    -- Wall jump
    self.xVel = -self.direction * self.wallJumpForce.x
    self.yVel = self.wallJumpForce.y
    self:stopClimbing()
  elseif self.hasDoubleJump then
    self.hasDoubleJump = false
    self.yVel = self.jumpAmount
  end
end

function Player:dash()
  if not self.isDashing and self.dashCooldownTimer <= 0 and self.isMoving then
    self.isDashing = true
    self.dashTimer = self.dashDuration
    self.dashCooldownTimer = self.dashCooldown
    self.isAirDashing = not self.grounded

    local dashDirection = { x = self.direction, y = 0 }

    self.xVel = dashDirection.x * self.dashSpeed
    self.yVel = dashDirection.y * self.dashSpeed * self.upwardDashMultiplier
  end
end

function Player:updateDash(dt)
  if self.isDashing then
    self.dashTimer = self.dashTimer - dt
    if self.dashTimer <= 0 then
      self.isDashing = false
      self.isAirDashing = false
    end
  end

  if self.dashCooldownTimer > 0 then
    self.dashCooldownTimer = self.dashCooldownTimer - dt
  end
end

function Player:decreaseGraceTime(dt)
  if not self.grounded then
    self.graceTime = self.graceTime - dt
  end
end

function Player:applyGravity(dt)
  if not self.grounded and not self.isAirDashing and not self.isClimbing then
    self.yVel = self.yVel + self.gravity * dt
  end
end

function Player:applyFriction(dt)
  local friction_amount = self.friction * dt
  if self.xVel > 0 then
    self.xVel = math.max(self.xVel - friction_amount, 0)
  elseif self.xVel < 0 then
    self.xVel = math.min(self.xVel + friction_amount, 0)
  end
end

function Player:land(collision)
  self.currentGroundCollision = collision
  self.yVel = 0
  self.grounded = true
  self.isMoving = false
  self.hasDoubleJump = true
  self.graceTime = self.graceDuration
end

function Player:syncPhysics()
  self.x, self.y = self.physics.body:getPosition()
  self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Player:beginContact(a, b, collision)
  if self.grounded then
    return
  end

  local nx, ny = collision:getNormal()

  if a == self.physics.fixture then
    if ny > 0 then
      self:land(collision)
    elseif ny < 0 then
      self.yVel = 0
    end
  elseif b == self.physics.fixture then
    if ny < 0 then
      self:land(collision)
    elseif ny > 0 then
      self.yVel = 0
    end
  end
end

function Player:endContact(a, b, collision)
  if a == self.physics.fixture or b == self.physics.fixture then
    if self.currentGroundCollision == collision then
      self.grounded = false
    end
  end
end

function Player:draw()
  local scaleX = self.direction
  love.graphics.setColor(self.color.red, self.color.green, self.color.blue)
  self.anim:draw(self.spriteSheet, self.x, self.y, 0, scaleX, 1, 16, 16)
  love.graphics.setColor(1, 1, 1, 1)
end

return Player
