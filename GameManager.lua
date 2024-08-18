local middleclass = require("lib/middleclass")

local GameManager = middleclass("GameManager")

function GameManager:initialize(states)
  self.empty = {
    render = function() end,
    update = function(self, dt) end,
    enter = function(self, enterParams) end,
    exit = function() end,
  }
  self.states = states or {} -- [name] -> [function that returns states]
  self.current = self.empty
  self.currentStateName = nil
end

function GameManager:change(stateName, enterParams)
  assert(self.states[stateName]) -- state must exist!

  if self.currentStateName == stateName then
    -- If we're changing to the same state, exit the current one first
    self.current:exit()
  end

  self.current:exit()
  self.current = self.states[stateName]() -- Create a new instance of the state
  self.currentStateName = stateName

  if enterParams ~= nil then
    self.current:enter(enterParams)
  else
    self.current:enter()
  end
end

function GameManager:update(dt)
  self.current:update(dt)
end

function GameManager:render()
  self.current:render()
end

return GameManager
