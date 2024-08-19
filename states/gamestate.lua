local middleclass = require("lib/middleclass")
local Constants = require("constants")
local Player = require("player")
local Coin = require("coin")
local Bolt = require("bolt")
local Camera = require("lib/camera")
local Spike = require("spikes")
local Wall = require("wall")
local BFL = require("bfl")
local GUI = require("gui")
local sti = require("lib/sti")

local GameState = middleclass("GameState")

function GameState:initialize(input)
  self.input = input
  self:reset()
end

function GameState:reset()
  self.player = nil
  self.gui = nil
  self.bfl = nil
  self.walls = {}
  self.camera = nil
  self.map = nil
  self.world = nil
  self.sounds = {}
end

function GameState:enter()
  self:reset() -- Reset the state before initializing
  love.graphics.setFont(Fonts["small"])

  -- Clear all existing physics objects
  if self.world then
    self.world:destroy()
  end

  self.world = love.physics.newWorld(0, 0)
  self.world:setCallbacks(function(...)
    self:beginContact(...)
  end, function(...)
    self:endContact(...)
  end)

  self.map = sti("assets/maps/scene1.lua", { "box2d" })

  -- Initialize map constants
  Constants.initializeMapConstants(self.map)

  self.map:box2d_init(self.world)
  self.map.layers.ground.visible = false
  self.map.layers.walls.visible = false

  self.walls = {}
  for _, object in ipairs(self.map.layers.walls.objects) do
    table.insert(self.walls, Wall:new(self.world, object.x, object.y, object.width, object.height))
  end

  -- Safely remove all spikes
  if Spike.removeAll then
    Spike.removeAll()
  else
    print("Warning: Spike.removeAll is not defined")
  end

  for _, object in ipairs(self.map.layers.spikes.objects) do
    Spike:new(object.x, object.y, math.rad(object.rotation), self.world)
  end

  local mapWidth = self.map.width * self.map.tilewidth
  local cameraStartX = mapWidth / 2
  local cameraStartY = Constants.MAP_BOTTOM - Constants.GAME_HEIGHT / 2

  self.camera = Camera(cameraStartX, cameraStartY, Constants.GAME_WIDTH, Constants.GAME_HEIGHT)
  self.camera.scale = 1

  self.sounds.music = love.audio.newSource("assets/audio/music/MegaHyperUltrastorm.mp3", "stream")
  self.sounds.music:setLooping(true)
  self.sounds.music:setVolume(0.3)
  -- self.sounds.music:play()

  self.player = Player:new(self.world)
  self.gui = GUI:new(self.player)
  self.bfl = BFL:new(self.world)
  self.gui:load()

  -- Safely remove all coins
  if Coin.removeAll then
    Coin.removeAll()
  else
    print("Warning: Coin.removeAll is not defined")
  end

  for _, object in ipairs(self.map.layers.coins.objects) do
    Coin:new(object.x, object.y, self.world)
  end

  -- Safely remove all coins
  if Bolt.removeAll then
    Bolt.removeAll()
  else
    print("Warning: Coin.removeAll is not defined")
  end

  for _, object in ipairs(self.map.layers.bolts.objects) do
    Bolt:new(object.x, object.y, self.world)
  end
end

function GameState:update(dt)
  self.world:update(dt)
  self.map:update(dt)
  self.player:update(dt)
  Coin.updateAll(dt)
  Bolt.updateAll(dt)
  Spike.updateAll(dt)
  -- self.bfl:update(dt)
  self.gui:update(dt)

  for _, wall in ipairs(self.walls) do
    wall:update(dt)
  end

  local moveX, moveY = self.input:get("move")
  self.player:move(dt, moveX, moveY)

  if self.input:pressed("jump") then
    self.player:jump()
  end

  -- if self.input:pressed("action") then
  --   self.player:dash()
  -- end

  if self.input:pressed("launch") then
    self.player:launch(self.camera)
  end

  -- Update camera to follow player
  self.camera:update(dt)
  self.camera:follow(self.player.x, self.player.y)
  self.camera:setFollowStyle("LOCKON")
  self.camera:setFollowLerp(0.1)

  -- Set camera bounds to map size
  local mapWidth = self.map.width * self.map.tilewidth
  local mapHeight = self.map.height * self.map.tileheight
  self.camera:setBounds(0, 0, mapWidth, mapHeight)

  if not self.player.isAlive then
    self.sounds.music:stop()
    gameManager:change("death")
  end
end

function GameState:render()
  self.camera:attach()

  love.graphics.setColor(1, 1, 1)
  self.map:draw(-self.camera.x, -self.camera.y, self.camera.scale, self.camera.scale)

  love.graphics.setColor(1, 1, 1)
  self.map:draw(
    -self.camera.x + Constants.GAME_WIDTH / (2 * self.camera.scale),
    -self.camera.y + Constants.GAME_HEIGHT / (2 * self.camera.scale),
    self.camera.scale,
    self.camera.scale
  )

  self.player:draw()
  Coin.drawAll()
  Bolt.drawAll()
  Spike.drawAll()
  self.bfl:draw()

  -- debug draws for collisions
  -- Spike.drawAllDebug()
  -- self.player:drawDebug()

  -- Draw text objects
  self:drawTextObjects()

  self.camera:detach()

  self.camera:draw()
  self.gui:draw()
end

function GameState:drawTextObjects()
  local tutorial_layer = self.map.layers["tutorial"]
  if tutorial_layer and tutorial_layer.objects then
    for i, obj in ipairs(tutorial_layer.objects) do
      if obj.shape == "text" then
        self:drawTextObject(obj)
      end
    end
  else
  end
end

function GameState:drawTextObject(obj)
  love.graphics.setColor(1, 1, 1, 0.35)

  local font = Fonts["small"]
  love.graphics.setFont(font)

  local text = love.graphics.newText(font, obj.text)
  local x, y = obj.x * self.camera.scale, obj.y * self.camera.scale

  -- Handle text alignment
  if obj.halign == "center" then
    x = x + obj.width / 2 - text:getWidth() / 2
  elseif obj.halign == "right" then
    x = x + obj.width - text:getWidth()
  end

  if obj.valign == "center" then
    y = y + obj.height / 2 - text:getHeight() / 2
  elseif obj.valign == "bottom" then
    y = y + obj.height - text:getHeight()
  end

  love.graphics.draw(text, math.floor(x), math.floor(y))
end

function GameState:exit()
  -- Clean up all game objects
  if self.world then
    self.world:destroy()
  end
  if Coin.removeAll then
    Coin.removeAll()
  end
  if Spike.removeAll then
    Spike.removeAll()
  end
  if self.player and self.player.destroy then
    self.player:destroy()
  end
  if self.bfl and self.bfl.destroy then
    self.bfl:destroy()
  end
  if self.sounds.music then
    self.sounds.music:stop()
  end
end

function GameState:beginContact(a, b, collision)
  if Coin.beginContact(a, b, collision) then
    return
  end
  if Spike.beginContact(a, b, collision) then
    return
  end
  if Wall.beginContact(a, b, collision) then
    return
  end
  if Bolt.beginContact(a, b, collision) then
    return
  end
  if BFL.beginContact(a, b, collision) then
    return
  end
  if self.player and self.player.beginContact then
    self.player:beginContact(a, b, collision)
  end
end

function GameState:endContact(a, b, collision)
  if Wall.endContact(a, b, collision) then
    return
  end
  if self.player and self.player.endContact then
    self.player:endContact(a, b, collision)
  end
end

return GameState
