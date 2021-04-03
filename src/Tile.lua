--[[
    TILE CLASS
    CS50G Project 3
    Match 3
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

Tile = Class{}

function Tile:init(x, y, color, variety)
    self.gridX = x
    self.gridY = y
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32
    self.color = color
    self.variety = variety
end

function Tile:render(x, y)
    love.graphics.draw(gTextures['tiles'], gFrames['tiles'][self.color][self.variety], self.x + x, self.y + y)
end