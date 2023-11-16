
--- 16/11/2023
--- Route definitions
---
--- table containing the arguments to initialise one RAT in each element
    --- gTrafficDataTable[1] = template name, [2] = departure list, [3] = destination list, [4] = commute [5] = starshape [6] = SpawnDelay, [7] = RespawnDelay, [8] = SpawnInterval
    gComAirDataTable = {{"COM NWA747", {"Antonio B. Won Pat Intl", "Saipan Intl"}, {"COMAIR Northeast", "COMAIR East"}, true, true, 300, 1800, 1200},
                         {"COM AFR727", {"Antonio B. Won Pat Intl"}, {"COMAIR Northeast", "COMAIR East"}, true, true, 150, 900, 600},
                        {"COM PHL737", {"Antonio B. Won Pat Intl", "Saipan Intil"}, {"COMAIR Southwest"}, true, true, 15, 600, 600},
                        {"COM AIN747", {"Antonio B. Won Pat Intl"}, {"COMAIR Northwest"}, true, true, 60, 500, 1800},
                        {"COM INDD9", {"Antonio B. Won Pat Intl", "Saipan Intl"}, {"COMAIR West"}, true, true, 30, 60, 15},
                        {"COM DHL757", {"Antonio B. Won Pat Intl", "Saipan Intl"}, {"COMAIR West", "COMAIR Southwest"}, true, true, 60, 300, 300},
                        {"COM DHLD10", {"Antonio B. Won Pat Intl"}, {"COMAIR Northeast"}, true, true, 300, 60, 120},
                        {"COM QFA747", {"Antonio B. Won Pat Intl"}, {"COMAIR Southeast"}, true, true, 0, 60, 600},
                        {"COM TNT737", {"Antonio B. Won Pat Intl", "Saipan Intl"}, {"COMAIR West", "COMAIR Southwest"}, true, true, 15, 60, 120},
                        {"COM SIN727", {"Antonio B. Won Pat Intl"}, {"COMAIR North, COMAIR Northwest", "COMAIR West"}, true, true, 60, 120, 300},
                        {"COM AFR747", {"Antonio B. Won Pat Intl"}, {"COMAIR Northwest"}, true, true, 120, 60, 400},
                        {"COM AAL757", {"Antonio B. Won Pat Intl"}, {"COMAIR Northeast"}, true, true, 90, 120, 60},
                        {"COM FDXD10", {"Antonio B. Won Pat Intl"}, {"COMAIR North", "COMAIR Northwest", "COMAIR East"}, true, true, 120, 90, 300},
                        {"COM SWID10", {"Antonio B. Won Pat Intl"}, {"COMAIR Northwest"}, true, true, 20, 500, 500},
                        {"COM DLH747", {"Antonio B. Won Pat Intl"}, {"COMAIR Northwest"}, true, true, 15, 300, 200},
                        {"COM THY747", {"Antonio B. Won Pat Intl"}, {"COMAIR East", "COMAIR North"}, true, true, 300, 150, 200},
                        {"COM PAA737", {"Antonio B. Won Pat Intl", "Saipan Intl"},{"COMAIR Southwest", "COMAIR West"}, true, true, 0, 300, 300},
                        {"COM NWA727", {"Antonio B. Won Pat Intl", "Saipan Intl"}, {"COMAIR Northwest", "COMAIR Northeast"}, true, true, 30, 300, 400},
                        {"COM FDX727", {"Antonio B. Won Pat Intl", "Saipan Intl"}, {"COMAIR Northwest", "COMAIR Northeast", "COMAIR East"}, true, true, 45, 120, 120},
                        {"COM PHL727", {"Antonio B. Won Pat Intl", "Saipan Intl"}, {"COMAIR East", "COMAIR Southeast"}, true, true, 15, 60, 120},
                        {"COM CHR727", {"Antonio B. Won Pat Intl"}, {"COMAIR North", "COMAIR East"}, true, true, 60, 15, 150},
                        {"COM KLM747", {"Antonio B. Won Pat Intl"}, {"COMAIR Northwest", "COMAIR Northeast"}, true, true, 30, 150, 300}}
    gGaTable = {}
    gMilTable = {}
    gNavyTable = {}
    --- holds instances of RAT
    gRatTable = {}

    --- RAT initialisation helper functions
    -- initialise RAT instance departures
    local function initDepartures(ratInstance, departureTable)
        return ratInstance:SetDeparture(departureTable)
    end

    -- initialise RAT instance destinations
    local function initDestinations(ratInstance, destinationTable)
        return ratInstance:SetDestination(destinationTable)
    end

    -- if boolCommute is true, rat instance passed in is initialised to commute
    -- if boolStarshape is true, RAT will return to starting location before travelling to a new destination
    local function initCommute(ratInstance, boolCommute, boolStarshape)
        if boolCommute == true then
            return ratInstance:Commute(boolStarshape)
        end
    end

    -- placeholder for alternative implementation using RAT:Spawn rather than RATMANAGER
    local function initTiming()

    end

    -- returns table containing instances of RAT initialised with helper functions using table of data passed in
    local function buildRatTable(ratData)
        local tempRat
        local tempRatTable = {}
        for i = 1, #ratData do
            tempRat = RAT:New(ratData[i][1])
            initDepartures(tempRat, ratData[i][2])
            initDestinations(tempRat, ratData[i][3])
            initCommute(tempRat, ratData[i][4], ratData[i][5])
            tempRatTable[i] = tempRat
        end
        return tempRatTable
    end

    -- adds instances of RAT from table argument to passed RATMANAGER
    local function initRatManager(ratManager, ratTable)
        for i = 1, #ratTable do
            ratManager:Add(ratTable[i], 1)
        end
    end

    -- instantiates new RATMANAGER and calls initRatManager to populate with instances of RAT from table argument
    local function newRatManager(ratTable, numAircraft)
        local tempRatManager = RATMANAGER:New(numAircraft)
        initRatManager(tempRatManager, ratTable)
        return tempRatManager
    end

    function main()
        comAirTrafficTable = buildRatTable(gComAirDataTable)
        newRatManager(comAirTrafficTable, 25)
        return 0
    end

    main()


