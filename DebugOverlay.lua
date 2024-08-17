-- Create a new file called DebugOverlay.lua with the following content:

local DebugOverlay = {}

DebugOverlay.messages = {}
DebugOverlay.maxMessages = 20  -- Adjust this to show more or fewer messages

function DebugOverlay.log(message)
    table.insert(DebugOverlay.messages, 1, tostring(message))
    if #DebugOverlay.messages > DebugOverlay.maxMessages then
        table.remove(DebugOverlay.messages)
    end
end

function DebugOverlay.clear()
    DebugOverlay.messages = {}
end

function DebugOverlay.draw()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 400, 15 * #DebugOverlay.messages)
    love.graphics.setColor(1, 1, 1, 1)
    for i, message in ipairs(DebugOverlay.messages) do
        love.graphics.print(message, 10, (i-1) * 15)
    end
end

return DebugOverlay
