--[[
    BOARD CLASS
    CS50G Project 3
    Match 3
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

Board = Class{}

function Board:init(level, x, y)
    self.x = x
    self.y = y
    self.level = level

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
            local color = math.random(#gFrames['tiles'])
            local variety = 0

            -- add a new variety at each level, until level 6
            if self.level == 1 then
                variety = 1
            else
                variety = math.random(1, self.level > 6 and 6 or self.level)
            end

            -- Tile has a 5 % chance to be shiny
            local shiny = math.random(20) == 1

            table.insert(self.tiles[y], Tile(
                -- coordinates are 0-based, so subtract one from index
                x, -- add board X offset to tile X
                y, -- add board Y offset to tile Y
                color,
                variety,
                shiny
            ))
        end
    end

    -- reinitialize board until there is no matches at startup
    while self:calculateMatches() do
        self:initializeBoard()
    end
end

function Board:swapTiles(selectedTile, newTile, tween, callback)
    local tmpX = selectedTile.gridX
    local tmpY = selectedTile.gridY

    selectedTile.gridX = newTile.gridX
    selectedTile.gridY = newTile.gridY
    newTile.gridX = tmpX
    newTile.gridY = tmpY

    self.tiles[selectedTile.gridY][selectedTile.gridX] = selectedTile
    self.tiles[newTile.gridY][newTile.gridX] = newTile

    if tween then
        -- animate swap
        Timer.tween(0.3, {
            [selectedTile] = { x = newTile.x, y = newTile.y },
            [newTile] = { x = selectedTile.x, y = selectedTile.y },
        }):finish(callback)
    end
end

function Board:checkPossibleMatches()
    local hasMatch = false

    for y = 1, 8 do
        for x = 1, 8 do
            local tile = self.tiles[y][x]
            -- if tile to swap is not off grid
            if x + 1 <= 8 then
                local rightTile = self.tiles[y][x + 1]
                -- swap tiles
                self:swapTiles(tile, rightTile)
                hasMatch = self:calculateMatches()
                -- unswap tiles
                self:swapTiles(tile, rightTile)
            end
            if x - 1 >= 1 then
                local leftTile = self.tiles[y][x - 1]
                self:swapTiles(tile, leftTile)
                hasMatch = self:calculateMatches()
                self:swapTiles(tile, leftTile)
            end
            if y + 1 <= 8 then
                local downTile = self.tiles[y + 1][x]
                self:swapTiles(tile, downTile)
                hasMatch = self:calculateMatches()
                self:swapTiles(tile, downTile)
            end
            if y - 1 >= 1 then
                local upTile = self.tiles[y - 1][x]
                self:swapTiles(tile, upTile)
                hasMatch = self:calculateMatches()
                self:swapTiles(tile, upTile)
            end
        end
    end

    if not hasMatch then
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
        local eraseEntireLine = false

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
                        -- if the tile is shiny, match the entire line and break the loop
                        -- because it's useless to check any other tile
                        if self.tiles[y][x2].shiny then
                            -- empty match before filling it with the entire line
                            match = self.tiles[y]
                            break
                        else
                            table.insert(match, self.tiles[y][x2])
                        end
                    end

                    -- add the match to the matches table
                    table.insert(matches, match)
                end

                -- reset counter
                colorMatchCount = 1

                if eraseEntireLine then
                    break
                end

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
                -- if one the matching tiles is shiny match the entire line
                if self.tiles[y][x].shiny then
                    match = self.tiles[y]
                else
                    table.insert(match, self.tiles[y][x])
                end
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
                        -- if the tile is shiny, match the entire line and break the loop
                        -- because it's useless to check any other tile
                        if self.tiles[y2][x].shiny then
                            -- empty match before filling it with the entire line
                            match = {}
                            for y3 = 1, 8 do
                                table.insert(match, self.tiles[y3][x])
                            end
                            break
                        else
                            table.insert(match, self.tiles[y2][x])
                        end
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
                -- if one the matching tiles is shiny match the entire line
                if self.tiles[y][x].shiny then
                     -- empty match before filling it with the entire line
                    match = {}
                    for x2 = 1, 8 do
                        table.insert(match, self.tiles[y][x2])
                    end
                    break
                else
                    table.insert(match, self.tiles[y][x])
                end
            end

            table.insert(matches, match)
        end
    end

    self.matches = matches

    return #self.matches > 0 and self.matches or false
end

function Board:getFallingTiles()
    local tweens = {}

    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            -- if last tile was a space
            local tile = self.tiles[y][x]

            if space then
                if tile then
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    self.tiles[y][x] = nil

                    tweens[tile] = { y = (tile.gridY - 1) * 32 }

                    -- set y to spaceY to start back from here
                    space = false
                    y = spaceY

                    -- reset to 0 to know 
                    spaceY = 0
                end
            elseif tile == nil then
                space = true

                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            if not tile then
                local color = math.random(#gFrames['tiles'])
                local variety = 0

                -- add a new variety at each level, until level 6
                if self.level == 1 then
                    variety = 1
                else
                    variety = math.random(1, self.level > 6 and 6 or self.level)
                end

                local newTile = Tile(x, y, color, variety)
                newTile.y = -32
                self.tiles[y][x] = newTile

                tweens[newTile] = { y = (newTile.gridY - 1) * 32 }
            end
        end
    end

    return tweens
end

function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for l, tile in pairs(match) do
            if tile.shiny then
                for x = 1, 8 do
                    self.tiles[tile.gridY][x] = nil
                end
            else
                self.tiles[tile.gridY][tile.gridX] = nil
            end
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