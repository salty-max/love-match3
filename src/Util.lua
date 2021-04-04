--[[
    UTIL FUNCTIONS
    CS50G Project 3
    Match 3
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

--[[
    Generate all the quads for the different tiles in the atlas, divided into tables for each set
    of tiles, since each color has 6 varieties.
--]]
function GenerateTileQuads(atlas)
    local tiles = {}
    local x = 0
    local y = 0
    local counter = 1

    -- 9 rows
    for row = 1, 9 do
        if row % 2 == 0 then
            --two sets of 6 tiles per row
            for i = 1, 2 do
                tiles[counter] = {}
    
                for col = 1, 6 do
                    table.insert(tiles[counter], love.graphics.newQuad(x, y, 32, 32, atlas:getDimensions()))
                    x = x + 32 -- tile width is 32
                end
    
                counter = counter + 1
            end
        end

        y = y + 32 -- tile height is 32
        x = 0
    end

    return tiles
end

--[[
    Recursive table printing function.
    https://coronalabs.com/blog/2014/09/02/tutorial-printing-table-contents/
]]
function print_r ( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end