--[[
    BOARD CLASS
    CS50G Project 3
    Match 3
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

Board = Class{}

function Board:init(x, y)
    self.x = x
    self.y = y
    self.tiles = {}

    -- each column of tiles
    for y = 1, 8 do
        --row of tiles
        table.insert(self.tiles, {})

        for x = 1, 8 do
            local color = math.random(18)
            local variety = math.random(6)
            table.insert(self.tiles[y], Tile(
                -- coordinates are 0-based, so subtract one from index
                x, -- add board X offset to tile X
                y, -- add board Y offset to tile Y
                color,
                variety
            ))
        end
    end
end

function Board:update(dt)

end

function Board:render()
    for y = 1, 8 do
        for x = 1, 8 do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end