--[[
    TILE CLASS
    CS50G Project 3
    Match 3
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

Tile = Class{}

function Tile:init(x, y, color, variety, shiny)
    self.gridX = x
    self.gridY = y
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32
    self.color = color
    self.variety = variety
    self.shiny = shiny
    self.blink = false
    self.score = 50 + (5 * self.variety)

    Timer.every(0.3, function()
        self.blink = not self.blink
    end)
end

function Tile:update(dt)
    Timer.update(dt)
end

function Tile:render(x, y)
    love.graphics.draw(gTextures['tiles'], gFrames['tiles'][self.color][self.variety], self.x + x, self.y + y)
    if self.shiny then
        if self.blink then
            love.graphics.setBlendMode('add')
            love.graphics.setColor(90/255, 90/255, 90/255, 150/255)
            love.graphics.rectangle('fill', self.x + x, self.y + y, 32, 32, 4)
        end
        love.graphics.setBlendMode('alpha')
        love.graphics.setColor(1, 1 ,1 ,1)
    end

end