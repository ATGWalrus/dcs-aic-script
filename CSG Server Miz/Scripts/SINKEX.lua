---
---
--- Generates a simple SINKEX for ASuW practice

    gShipTable = {"SINKEX Large", "SINKEX Medium"}
    gSINKEXZone = ZONE:FindByName("SINKEX Zone")
    local lSpawnMenuTable = {}  -- stores instances of MENU calling function to spawn a GROUP
    local DeleteMenuTable = {}  -- stores instances of MENU calling function to delete a GROUP
    local lSpawnedTable = {}    -- instances of GROUP spawned by this script will be stored in this table
    local SINKEXtopMenu = MENU_COALITION:New(coalition.side.BLUE, "SINKEX")
    local SINKEXspawnMenu = MENU_COALITION:New(coalition.side.BLUE, "Begin SINKEX", SINKEXtopMenu)
    --local SINKEXdeleteMenu = MENU_COALITION:New(coalition.side.BLUE, "Delete a Ship", SINKEXtopMenu)

    -- calls MENU:Remove for the instance of MENU referenced by menuTable[index]
    local function deleteDeleteMenu(index, menuTable)
        menuTable[index]:Remove()
        menuTable[index] = 0
    end

    -- iteratively searches for element of lSpawnedTable matching passed index and deletes the GROUP to which that element holds a reference
    local function deleteShip(spawnIndex, index, menuTable)
        for i = 1, #lSpawnedTable do
            if i == spawnIndex then
                lSpawnedTable[i]:Destroy(false, 1)
            end
        end
        deleteDeleteMenu(index, menuTable)
    end

    --- build SINKEX delete ship menu
    -- creates a new instance of MENU calling function to delete ship in lSpawnedTable[index] and stores reference in menuTable,
    local function buildSINKEXdeleteMenu(tableIndex, menuTable)
        menuTable[#menuTable + 1] = MENU_COALITION_COMMAND:New(coalition.side.BLUE,
                "Delete Ship " .. tostring(#lSpawnedTable), SINKEXdeleteMenu, deleteShip, tableIndex, #lSpawnedTable, menuTable)
    end

    --- helper functions for spawning Ships
    -- spawns a ship of type passed in at a random location in zone argument
    local function spawnShip(ship, zone)
        local newShip = SPAWN:NewWithAlias(ship, ship)
        newShip:SpawnInZone(zone, true)
        lSpawnedTable[#lSpawnedTable + 1] = newShip
    end

    -- calls functions to spawn a new ship and create a menu for its deletion
    local function SINKEXhelper(ship, zone, menuTable)
        spawnShip(ship, zone)
        --buildSINKEXdeleteMenu(#lSpawnedTable, menuTable)
    end

    --- build SINKEX menu
    -- creates an instance of MENU for each element of gShipTable
    -- could be readily extended to accommodate multiple zones/other options
    local function buildSINKEXspawnMenu(shipTable, zone, menuTable)
        for i = 1, #shipTable do
            lSpawnMenuTable[i] = MENU_COALITION_COMMAND:New(coalition.side.BLUE,
                    "Spawn a " .. shipTable[i] .. " ship for SINKEX ", SINKEXspawnMenu, SINKEXhelper, shipTable[i], zone, menuTable)
        end
    end

    function main()
        buildSINKEXspawnMenu(gShipTable, gSINKEXZone, DeleteMenuTable)
        return 0
    end

    main()


