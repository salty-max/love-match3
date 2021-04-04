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

    self.matches = {}

    self:initializeBoard()
end

function Board:initializeBoard()
    self.tiles = {}

    -- each column of tiles
    for y = 1, 8 do
        --row of tiles
        table.insert(self.tiles, {})

        for x = 1, 8 do
            local color = math.random(18)
            local variety = 1
            table.insert(self.tiles[y], Tile(
                -- coordinates are 0-based, so subtract one from index
                x, -- add board X offset to tile X
                y, -- add board Y offset to tile Y
                color,
                variety
            ))
        end
    end

    -- reinitialize board until there is no matches at startup
    while self:calculateMatches() do
        self:initializeBoard()
    end
end

function Board:calculateMatches()
    local matches = {}
    local colorMatchCount = 0

    -- horizontal matches
    for y = 1, 8 do
        -- store first tile color
        local colorToMatch = self.tiles[y][1].color
        colorMatchCount = 1

        -- go through every tile in the row
        for x = 2, 8 do
            -- if colors match, increment counter
            if self.tiles[y][x].color == colorToMatch then
                colorMatchCount = colorMatchCount + 1
            else
                -- set color to match to the current tile one
                colorToMatch = self.tiles[y][x].color

                -- check if before this tile there was a match
                if colorMatchCount >= 3 then
                    local match = {}
                    -- go backwards to store every tile in the match
                    for x2 = x - 1, x - colorMatchCount, -1 do
                        table.insert(match, self.tiles[y][x2])
                    end

                    -- add the match to the matches table
                    table.insert(matches, match)
                end

                -- reset counter
                colorMatchCount = 1

                -- no need to check for matches on the last column
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if colorMatchCount >= 3 then
            local match = {}
            
            -- go backwards from end of last row by colorMatchCount
            for x = 8, 8 - colorMatchCount + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        -- store first tile color
        local colorToMatch = self.tiles[1][x].color
        colorMatchCount = 1

        -- go through every tile in the row
        for y = 2, 8 do
            -- if colors match, increment counter
            if self.tiles[y][x].color == colorToMatch then
                -- increment counter
                colorMatchCount = colorMatchCount + 1
            else
                -- set color to match to the current tile one
                colorToMatch = self.tiles[y][x].color

                -- check if before this tile there was a match
                if colorMatchCount >= 3 then
                    local match = {}
                    -- go backwards to store every tile in the match
                    for y2 = y - 1, y - colorMatchCount, -1 do
                        table.insert(match, self.tiles[y2][x])
                    end

                    -- add the match to the matches table
                    table.insert(matches, match)
                end

                -- reset counter
                colorMatchCount = 1

                -- no need to check for matches on the last row
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if colorMatchCount >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for y = 8, 8 - colorMatchCount + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    self.matches = matches

    return #self.matches > 0 and self.matches or false
end

function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for l, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            if self.tiles[y][x] then
                self.tiles[y][x]:render(self.x, self.y)
            end
        end
    end
end