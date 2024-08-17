local middleclass = require("lib/middleclass")
local Constants = require("constants")

local GUI = middleclass("GUI")

function GUI:initialize(player)
    self.player = player
    self:load()
end

function GUI:load()
    self.launch = {}
    self.launch.color = { 1, 0, 0, 0.7 } -- Red color with some transparency
    self.launch.x = 0
    self.launch.y = Constants.GAME_HEIGHT - 10
    self.launch.width = 5
    self.launch.height = 5
    self.launch.scale = 2
    self.launch.spacing = self.launch.width * self.launch.scale + 5
end

function GUI:update(dt)
    -- Update logic if needed
end

function GUI:draw()
    self:displayLaunchInfo()
end

function GUI:displayLaunchInfo()
    for i = 1, self.player.launchRemaining do
        local x = self.launch.x + self.launch.spacing * i
        love.graphics.setColor(self.launch.color)
        love.graphics.circle("fill", x, self.launch.y, 5, 5)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return GUI
