local middleclass = require("lib/middleclass")
local Constants = require("constants")
local Camera = require("lib/camera")
local Wall = require("wall")
local Player = require("player")
local Coin = require("coin")
local Fuel = require("fuel")
local Bolt = require("bolt")
local Spike = require("spikes")
local Zapper = require("zapper")
local Win = require("winPoint")
local BFL = require("bfl")
local GUI = require("gui")
local sti = require("lib/sti")

local GameState = middleclass("GameState")

local coins

local function getPlayerStartPoint(map, checkpointNumber)
  local playerStartLayer = map.layers.player_start
  if not playerStartLayer then
    return nil
  end

  for _, object in ipairs(playerStartLayer.objects) do
    if object.properties and object.properties.checkpoint == checkpointNumber then
      return object
    end
  end

  return nil
end

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
  self.gameWin = nil
  self.zappers = {}
end

function GameState:enter(params)
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

  Fuel.setWorld(self.world)

  self.map = sti("assets/maps/scene1.lua", { "box2d" })

  -- Initialize map constants
  Constants.initializeMapConstants(self.map)

  self.map:box2d_init(self.world)
  self.map.layers.ground.visible = false
  self.map.layers.walls.visible = false
  self.map.layers.game_win.visible = false
  self.map.layers.zappers.visible = false

  self.gameWin = self.map.layers.game_win.objects[1]

  self.winArea = Win:new(self.world, self.gameWin.x, self.gameWin.y, self.gameWin.width, self.gameWin.height)

  self.walls = {}
  for _, object in ipairs(self.map.layers.walls.objects) do
    table.insert(self.walls, Wall:new(self.world, object.x, object.y, object.width, object.height))
  end

  if Zapper.removeAll then
    Zapper.removeAll()
  end

  local zapperLayerData = self.map.layers.zappers
  if zapperLayerData then
    self.zappers = Zapper.createAllFromTiledData(zapperLayerData, self.world)
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

  local checkpoint = 4
  local playerStartPoint = getPlayerStartPoint(self.map, checkpoint)
  local playerX
  local playerY

  if playerStartPoint then
    playerX = playerStartPoint.x
    playerY = playerStartPoint.y
  end

  self.player = Player:new(self.world, playerX, playerY)
  self.gui = GUI:new(self.player)

  local bflEnabled = params and params.bfl or false
  if bflEnabled then
    self.bfl = BFL:new(self.world)
  end

  self.gui:load()

  if Coin.removeAll then
    Coin.removeAll()
  else
    print("Warning: Coin.removeAll is not defined")
  end

  for _, object in ipairs(self.map.layers.coins.objects) do
    Coin:new(object.x, object.y, self.world, object.type)
  end

  if Bolt.removeAll then
    Bolt.removeAll()
  else
    print("Warning: Coin.removeAll is not defined")
  end

  for _, object in ipairs(self.map.layers.bolts.objects) do
    Bolt:new(object.x, object.y, self.world)
  end

  if Fuel.removeAll then
    Fuel.removeAll()
  end

  for _, object in ipairs(self.map.layers.fuel.objects) do
    Fuel:new(object.x, object.y)
  end
end

function GameState:update(dt)
  self.world:update(dt)
  self.map:update(dt)
  Coin.updateAll(dt)
  Bolt.updateAll(dt)
  Fuel.updateAll(dt)
  Spike.updateAll(dt)
  self.gui:update(dt)

  for _, zapper in ipairs(self.zappers) do
    zapper:update(dt)
  end

  if self.bfl then
    self.bfl:update(dt)
  end

  for _, wall in ipairs(self.walls) do
    wall:update(dt)
  end
 if self.winArea then
    self.winArea:update(dt)
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
  self.camera:setFollowLerp(0.4)

  -- Set camera bounds to map size
  local mapWidth = self.map.width * self.map.tilewidth
  local mapHeight = self.map.height * self.map.tileheight
  self.camera:setBounds(0, 0, mapWidth, mapHeight)

  if self.player then
    if not self.player.isAlive then
      self:handleDeath()
      return
    end

    self.player:update(dt)

    if self.winArea and self.winArea:checkPlayerWin(self.player) then
      self:handleWin()
      return
    end
  end

  coins = self.player.coins
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
  Fuel.drawAll()
  Spike.drawAll()

  if self.winArea then
    self.winArea:draw()
  end
  for _, zapper in ipairs(self.zappers) do
    zapper:draw()
  end

  if self.bfl then
    self.bfl:draw()
  end

  -- debug draws for collisions
  -- Spike.drawAllDebug()
  -- self.player:drawDebug()
  -- for _, zapper in ipairs(self.zappers) do
  --   zapper:drawDebug()
  -- end

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

function GameState:handleDeath()
  if not self.gameOver then
    self.gameOver = true
    if self.sounds.music then
      self.sounds.music:stop()
    end
    gameManager:change("death")
  end
end

function GameState:handleWin()
  if not self.gameOver then
    self.gameOver = true
    if self.sounds.music then
      self.sounds.music:stop()
    end
    if self.player then
      self.player:destroy()
      self.player = nil
    end
    gameManager:change("win", { coins = coins })
  end
end

function GameState:exit()
  if self.world then
    if self.player then
      self.player:destroy()
      self.player = nil
    end
    self.world:destroy()
    self.world = nil
  end
  if Coin.removeAll then
    Coin.removeAll()
  end
  if Spike.removeAll then
    Spike.removeAll()
  end
  if Bolt.removeAll then
    Bolt.removeAll()
  end
  if Fuel.removeAll then
    Fuel.removeAll()
  end
  for _, zapper in ipairs(self.zappers) do
    zapper:destroy()
  end
  self.zappers = {}
  if self.sounds.music then
    self.sounds.music:stop()
  end
end

function GameState:beginContact(a, b, collision)
  if Zapper.beginContact(a, b, collision) then
    return
  end
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
  if Fuel.beginContact(a, b, collision) then
    return
  end
  if Win.beginContact(a, b, collision) then
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
