local anim8 = require("lib/anim8")
Player = require("player")

local Coin = { spriteSheet = love.graphics.newImage("assets/sprites/coin.png") }

Coin.__index = Coin

Coin.width = 11
Coin.height = 11

ActiveCoins = {}

function Coin.new(x, y)
  local instance = setmetatable({}, Coin)
  instance.x = x
  instance.y = y
  instance.scaleX = 1
  instance.randomTimeOffset = math.random(0, 100)
  instance.toBeRemoved = false

  instance.grid = anim8.newGrid(11, 11, instance.spriteSheet:getWidth(), instance.spriteSheet:getHeight())
  instance.animation = anim8.newAnimation(instance.grid("1-4", 1), 0.15)

  instance.physics = {}
  instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
  instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
  instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
  instance.physics.fixture:setSensor(true)
  table.insert(ActiveCoins, instance)
end

function Coin:draw()
  self.animation:draw(self.spriteSheet, self.x, self.y, 0, self.scaleX, 1, 11, 11)
end

function Coin.drawAll()
  for i, instance in ipairs(ActiveCoins) do
    instance:draw()
  end
end

function Coin:update(dt)
  self.animation:update(dt)
  self:checkRemove()
end

function Coin.updateAll(dt)
  for i, instance in ipairs(ActiveCoins) do
    instance:update(dt)
  end
end

function Coin:remove()
  for i, instance in ipairs(ActiveCoins) do
    if instance == self then
      Player:incrementCoins()
      print(Player.coins)
      self.physics.body:destroy()
      table.remove(ActiveCoins, i)
    end
  end
end

function Coin:checkRemove()
  if self.toBeRemoved then
    self:remove()
  end
end

function Coin.beginContact(a, b, collision)
  for i, instance in ipairs(ActiveCoins) do
    if a == instance.physics.fixture or b == instance.physics.fixture then
      if a == Player.physics.fixture or b == Player.physics.fixture then
        instance.toBeRemoved = true
        return true
      end
    end
  end
end

return Coin
