
    --- 16/11/2023
    --- Implemented for maximum portability and reusability
    ---functions are entirely independent of any DCS map or asset and will work with any data supplied in the specified format

    --- table containing the arguments to initialise one RAT in each element
    --- gTrafficDataTable[1] = template name, [2] = departure list, [3] = destination list, [4] = commute [5] = starshape [6] = SpawnDelay, [7] = RespawnDelay, [8] = SpawnInterval
    --- probably should be moved to an external file to clean up script
    gComAirDataTable = {--[[]{"COM NWA747", {"COMAIR Northeast", "COMAIR East", "COMAIR ENE", "COMAIR NNE"}, {"Antonio B. Won Pat Intl", "Saipan Intl"}, true, true, 300, 1800, 1200},--]]
        {"COM AFR727", {"Antonio B. Won Pat Intl"}, {"COMAIR Northeast", "COMAIR East", "COMAIR ENE", "COMAIR NNE"}, true, true, 150, 900, 600},
        {"COM PHL737", {"COMAIR Southwest"}, {"Antonio B. Won Pat Intl"}, true, true, 15, 600, 600},
        {"COM AIN747", {"Antonio B. Won Pat Intl"}, {"COMAIR Northwest", "COMAIR NNNW", "COMAIR NW2"}, true, true, 60, 500, 1800},
        {"COM INDD9", {"Antonio B. Won Pat Intl", "Saipan Intl"}, {"COMAIR West", "COMAIR WNW", "COMAIR WWNW"}, true, true, 30, 60, 15},
        {"COM DHL757", {"COMAIR West", "COMAIR Southwest"}, {"Antonio B. Won Pat Intl", "Saipan Intl"}, true, true, 60, 300, 300},
        {"COM DHLD10", {"Antonio B. Won Pat Intl"}, {"COMAIR Northeast", "COMAIR ENE"}, true, true, 300, 60, 120},
        {"COM QFA747", {"Antonio B. Won Pat Intl"}, {"COMAIR Southeast"}, true, true, 0, 60, 600},
        {"COM TNT737", {"COMAIR West", "COMAIR Southwest", "COMAIR WWNW"}, {"Antonio B. Won Pat Intl", "Saipan Intl"}, true, true, 15, 60, 120},
        {"COM SIN727", {"COMAIR North", "COMAIR Northwest", "COMAIR West", "COMAIR NW2", "COMAIR NNW"}, {"Antonio B. Won Pat Intl"}, true, true, 60, 120, 300},
        {"COM AFR747", {"Antonio B. Won Pat Intl"}, {"COMAIR Northwest", "COMAIR NW2", "COMAIR NNW"}, true, true, 120, 60, 400},
        {"COM AAL757", {"Antonio B. Won Pat Intl"}, {"COMAIR Northeast", "COMAIR ENE"}, true, true, 90, 120, 60},
        {"COM FDXD10", {"COMAIR North", "COMAIR Northwest", "COMAIR East"}, {"Antonio B. Won Pat Intl"}, true, true, 120, 90, 300},
        {"COM SWID10", {"Antonio B. Won Pat Intl", "COMAIR Northwest"}, {"COMAIR Northwest", "COMAIR NW2", "COMAIR NNW", "COMAIR WEST"}, true, true, 20, 500, 500},
        {"COM DLH747", {"COMAIR Northwest"}, {"Antonio B. Won Pat Intl"}, true, true, 15, 300, 200},
        {"COM THY747", { "COMAIR East", "COMAIR North"}, {"Antonio B. Won Pat Intl"}, true, true, 300, 150, 200},
        {"COM PAA737", {"Antonio B. Won Pat Intl", "Saipan Intl"},{"COMAIR Southwest", "COMAIR West"}, true, true, 0, 300, 300},
        {"COM NWA727", {"COMAIR Northwest", "COMAIR Northeast"}, {"Antonio B. Won Pat Intl", "Saipan Intl"}, true, true, 30, 300, 400},
        {"COM FDX727", {"Antonio B. Won Pat Intl", "Saipan Intl","COMAIR East"}, {"COMAIR Northwest", "COMAIR Northeast"}, true, true, 45, 120, 120},
        {"COM PHL727", {"COMAIR East", "COMAIR Southeast", "COMAIR South"}, {"Antonio B. Won Pat Intl", "Saipan Intl"}, true, true, 15, 60, 120},
        {"COM CHR727", {"Antonio B. Won Pat Intl", "COMAIR North", "COMAIR East"}, {"COMAIR North", "COMAIR East"}, true, true, 60, 15, 150},
        {"COM KLM747", {"COMAIR Northwest", "COMAIR Northeast"}, {"Antonio B. Won Pat Intl"}, true, true, 30, 150, 300}}

    gMilAirDataTable = {{"MIL USC5", {"MIL Northeast"}, {"Andersen AFB"}, true, true, 600, 100, 300},
                        {"MIL AU130", {"COMAIR South", "COMAIR Southeast"}, {"Andersen AFB"}, true, true, 300, 600, 100},
                        {"MIL RC135", {"Andersen AFB"}, {"MIL Northeast", "MIL West", "COMAIR NNNW"}, true, true, 500, 600, 200},
                        {"MIL USB52", {"Andersen AFB"}, {"MIL Northeast", "MIL West", "COMAIR NW2"}, true, true, 800, 600, 300},
                        {"MIL USNC9", {"COMAIR SouthEast", "MIL Northeast"}, {"Andersen AFB"}, true, true, 600, 300, 180}}


    gNavAirDataTable = {{"NAV USC2", {"Andersen AFB", "Saipan Intl", "USS Theodore Roosevelt"}, {"Andersen AFB", "Saipan Intl", "USS Theodore Roosevelt"}, true, true, 300, 300, 800}}


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
    local function initTiming(foo)
        return bar
    end

    -- returns table containing instances of RAT initialised with helper functions using table of data passed in
    -- RAT instances are instantiated and initialised iteratively
    local function buildRatTable(ratData)
        local tempRat
        local tempRatTable = {}
        for i = 1, #ratData do
            tempRat = RAT:New(ratData[i][1])
            initDepartures(tempRat, ratData[i][2])
            initDestinations(tempRat, ratData[i][3])
            initCommute(tempRat, ratData[i][4], ratData[i][5])
            tempRat:ATC_Messages(false)
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
    local function newRatManager(ratDataTable, numAircraft)
        local tempRatTable = buildRatTable(ratDataTable)
        local tempRatManager = RATMANAGER:New(numAircraft)
        initRatManager(tempRatManager, tempRatTable)
        return tempRatManager
    end

    function main()
        comAirRatManager = newRatManager(gComAirDataTable, 25)
        navAirRatManager = newRatManager(gNavAirDataTable, 2)
        milAirRatManager = newRatManager(gMilAirDataTable, 4)
        comAirRatManager:SetTspawn(120)
        comAirRatManager:Start()
        navAirRatManager:Start()
        milAirRatManager:SetTspawn(60)
        milAirRatManager:Start()
        return 0
    end

    main()


