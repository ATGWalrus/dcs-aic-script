---
---
--- Script to spawn and manage groups configured in specific formations and multi-group presentations
--- For ease of implementation, the centre from which spawn locations are derived is set as a ship or airbase object
--- The characteristics of a given presentation are stored in an array of format: {presentationName, num aircraft {vec3 locationOne}, {vec3 locationTwo}, ..}
--- Presentations will be spawned on a bearing from the centre point and with a semi-randomly determined heading
--- inspiration has drawn from an unattributed script "F10MenuScript_Air.lua" sent to me in 2022
--- Charles T. Wild (Walrus) 2023
---
--- Initial goals: spawn group on randomised-within-bounds bearing and range from centre point - achieved
--- Next: implement two group range

    BASE:TraceOnOff(true)
    BASE:TraceLevel(1)
    BASE:TraceClass("SPAWN")

    --MESSAGE:New(gAircraftTypeTable[1][1]):ToAll()

    -- helper functions
    local function nmToMetres(nauticalMiles)
        return nauticalMiles * 1852
    end

    local function ftToMetres(feet)
        return feet * 0.3048
    end

    local function randomAltitude(min, max)
        if min == nil then
            return math.random(gMinAltitude, gMaxAltitude)
        else
            return math.random(min, max)
        end
    end

    local function randomBearing()
        return math.random(1, 360)
    end

    local function randomRange(min, max) -- called by randomDeltaX & Y to find range from centre at which group will be spawned
        if min or max ~= nil then
            return math.random(min, max) -- if arguments are passed in, range is determined between these
        else
            BASE:E("calculating deltaY from min")
            return math.random(gMinSpawnRange, gMaxSpawnRange) -- otherwise uses globals for calculation
        end
    end

    local function randomDeltaX(bearing, min, max)
        if max ~= nil then
            return randomRange(min, max) * math.cos(math.rad(bearing))
        else
            BASE:E("calculating deltaX from min " .. tostring(min))
            return min * math.cos(math.rad(bearingToNinety(bearing)))
        end
    end

    local function randomDeltaZ(bearing, min, max)
        if max ~= nil then
            return randomRange(min, max) * math.sin(math.rad(bearing))
        else
            BASE:E("calculating deltaZ from min " .. tostring(min))
            return min * math.sin(math.rad(bearingToNinety(bearing)))
        end
    end

    local function bearingFrom(presentationBearing, heading) -- calculates offset between two bearings; if 180 is passed as either argument, will calculate reciprocal
        if presentationBearing + heading == 360 then
            return 360
        else
            return ((presentationBearing + heading) % 360)
        end
    end

    --- globals
    BASE:E("above gCentre")
    gCentre = POINT_VEC2:New(36199, 268314) -- centre from which spawn location will be derived. Predicated on script being loaded on Syria map
    BASE:E("below gCentre")
    gMaxGroupSize = 4
    gMinGroupSize = 1
    gMaxSpawnRange = nmToMetres(200) -- max range from gCentre at which groups can be spawned
    gMinSpawnRange = nmToMetres(100) -- min range ditto above
    gMaxAltitude = ftToMetres(35000) -- max altitude at which a group can be spawned
    gMinAltitude = ftToMetres(2500) -- min altitude ditto above

    --- presentation, aircraft and spawned groups tables
    --- each element contains: [1] presentation name [2] number of aircraft, [3] min separation, [4] max separation, [5] table of bearings from lead to trail groups
    gPresentationTypeTable	= {{"Azimuth", 2, nmToMetres(7), nmToMetres(17), {270}},
                                 {"Range", 2, nmToMetres(10), nmToMetres(20), {180}},
                                 {"Vic", 3, nmToMetres(6), nmToMetres(12), {135, 225}},
                                 {"Ladder", 3, nmToMetres(7), nmToMetres(12), {180}},
                                 {"Wall", 3, nmToMetres(7), nmToMetres(15), {90, 270}},
                                 {"singleGroup", 1, 0, 0, {}},
                                 {"Echelon", 2, nmToMetres(7), nmToMetres(17), {200}},
                                 {"Champagne", 3, nmToMetres(7), nmToMetres(17), {45, 315}},
                                 {"2Stack"}, {"3Stack"}, {"Box"}}

    gAircraftTypeTable = {{"F-4", "fighter", "blue"}, {"F-5", "fighter", "blue"}, {"F-14", "fighter", "blue"},
                          {"F-15", "fighter", "blue"}, {"F-16", "fighter", "blue"}, {"F-18", "fighter", "blue"},
                          {"Fagot", "fighter", "red"}, {"Farmer", "fighter", "red"}, {"Fishbed", "fighter", "red"},
                          {"Flogger", "fighter", "red"}, {"Fulcrum", "fighter", "red"}, {"Flanker", "fighter", "red"}}
    gSpawnedTable = {}

    --- returns a string containing a group name (these MUST conform with group names in ME)
    function randomAircraft()
        local selection = math.random(#gAircraftTypeTable)
        for i = 1, selection do
            if i == selection then
                return gAircraftTypeTable[i][1]
            end
        end
    end

    --- Finds random location and returns it in a POINT_VEC3
    function getRandomLocation(centre, min, max, bearing)
        BASE:E("getRandomLocation")
        local x = centre.x + randomDeltaX(bearing, min, max)
        BASE:E("x = " .. tostring(x))
        local y = randomAltitude()
        local z = centre.y + randomDeltaZ(bearing, min, max)
        --BASE:E("z = " .. tostring(z))
        --MESSAGE:New(z, 25):ToAll()
        local locationObj = POINT_VEC3:New(x, y, z)
        return locationObj
    end

    function checkAlive(group)
        if group:IsAlive() == true then
            return true
        else
            return false
        end
    end

    function spawnSingleGroupAtRandomLocation()
        BASE:E("spawnRandom")
        MESSAGE:New("spawnRandom", 40):ToAll()
        local spawnPoint = getRandomLocation()
        spawnGroup(spawnPoint)
    end

    function spawnGroup(location, heading)
        local type = randomAircraft()
        if gSpawnedTable[1] == nil then -- Check if table is empty and add reference to new group in first element if it is
            BASE:E("table empty")
            local newGroup = SPAWN:NewWithAlias(type, "SpawnAliasPrefix")
            newGroup:InitHeading(heading)
            newGroup:InitGroupHeading(heading)
            newGroup:SpawnFromPointVec3(location)
            gSpawnedTable[1] = newGroup
            newGroup = nil
            BASE:E("newGroup sanitised")
        else
            BASE:E("table not empty")
            local spawnIndex = #gSpawnedTable + 1
            local newGroup = SPAWN:NewWithAlias(type, "SpawnAliasPrefix" .. spawnIndex)
            newGroup:InitHeading(heading)
            newGroup:InitGroupHeading(heading)
            newGroup:SpawnFromPointVec3(location)
            gSpawnedTable[spawnIndex] = newGroup
            newGroup = nil
            BASE:E("newGroup sanitised")
        end
    end

    function selectPresentation(presentation)
        for i = 1, #gPresentationTypeTable do
            if gPresentationTypeTable[i] == presentation then
                return gPresentationTypeTable[i]
            end
        end
    end

    function calculateOffsetPos(bearingFromLead, origin, separation)
        local z = origin.z + (separation * math.sin(math.rad(bearingFromLead)))
        local y = randomAltitude()
        local x = origin.x + (separation * math.cos(math.rad(bearingFromLead)))
        local locationObj = POINT_VEC3:New(x, y, z)
        return locationObj
    end

    function spawnPresentation(selectedPresentation)
        local leadPosition = getRandomLocation(gCentre, gMinSpawnRange, gMaxSpawnRange, randomBearing())
        local groupHeading = randomBearing()
        local separation = randomRange(selectedPresentation[3], selectedPresentation[4])
        spawnGroup(leadPosition, groupHeading)
        for i = 1, #selectedPresentation[5] do
            local angleOff = selectedPresentation[5][i] + groupHeading
            spawnGroup(calculateOffsetPos(angleOff, leadPosition, separation), groupHeading)
        end
        MESSAGE:New(selectedPresentation[2] .. "-group " .. selectedPresentation[1] .. " presentation spawned"):ToAll()
    end

    function testCallSelectPresentation()
        local presentationSelect = math.random(1, 8)
        spawnPresentation(gPresentationTypeTable[presentationSelect])
        BASE:E("presentation selected")
    end

    local testRangeTimer=TIMER:New(testCallSelectPresentation):Start(2, 5, 100) -- timer calls function creating new groups every five seconds for testing

    ---deprecated code
    --[[
        function zSinCosX(bearing, origin, separation)
        local modBearing = (bearing % 90)
        local deltaZ = math.sin(math.rad(modBearing)) * separation
        local deltaX = math.cos(math.rad(modBearing)) * separation
        local z = origin.z + deltaZ
        --BASE:E("delta z calculated")
        local y = randomAltitude()
        --BASE:E("y calculated")
        --BASE:E("origin.x " .. origin.x)
        local x = origin.x + deltaX
        local locationObj = POINT_VEC3:New(x, y, z)
        return locationObj
    end

    function minusZSinCosX(bearing, origin, separation)
        local modBearing = (90 - (bearing % 90))
        local deltaZ = math.sin(math.rad(modBearing)) * separation
        local deltaX = math.cos(math.rad(modBearing)) * separation
        local z = origin.z - deltaZ
        local y = randomAltitude()
        local x = origin.x + deltaX
        local locationObj = POINT_VEC3:New(x, y, z)
        return locationObj
    end

    function testDeltaCalc()
        presentation = gPresentationTypeTable[3]
        leadPosition = getRandomLocation(gCentre, gMinSpawnRange, gMaxSpawnRange, randomBearing()) -- type POINT_VEC3
        groupHeading = randomBearing()
        separation =  randomRange(5000, 10000)
        headingRecip = ((groupHeading + 180) % 360)
        if (headingRecip > 0 and headingRecip <= 90) or (headingRecip > 180 and headingRecip <= 270) then
            trailPosition = zSinCosX(headingRecip, leadPosition, separation)
       elseif (headingRecip > 90 and headingRecip <= 180) or (headingRecip > 270 and headingRecip <= 360) then
            trailPosition = minusZSinCosX(headingRecip, leadPosition, separation)
        end
        spawnGroup(leadPosition, groupHeading)
        spawnGroup(trailPosition, groupHeading)
        leadPosition = nil
        trailPosition = nil
    end

        function twoGroupHelper(presentation)
        --BASE:E("two group helper top")
        local leadPosition = getRandomLocation(gCentre, gMinSpawnRange, gMaxSpawnRange, randomBearing()) -- set lead group position
        local trailPosition -- initialise trailPosition as local to this function
        local groupHeading = randomBearing() -- get random heading for group - this will be used to calculate the bearing from lead at which to spawn second/trail group
        --BASE:E("groupHeading " .. tostring(groupHeading))
        local separation = randomRange(presentation[3], presentation[4]) -- distance between lead and trail groups
        local headingRecip = bearingFrom(presentation[5], groupHeading)
        --BASE:E("lead position calculated " .. tostring(leadPosition.x) .. ", " .. tostring(leadPosition.z))
        if (headingRecip > 0 and headingRecip <= 90) or (headingRecip > 180 and headingRecip <= 270) then
            trailPosition = zSinCosX(bearingFrom(presentation[5], groupHeading), leadPosition, separation)
        elseif (headingRecip > 90 and headingRecip <= 180) or (headingRecip > 270 and headingRecip <= 360) then
            trailPosition = minusZSinCosX(bearingFrom(presentation[5], groupHeading), leadPosition, separation)
        end -- position of trail group is calculated using lead position and data from presentation table
        --BASE:E("trail position calculated " .. tostring(trailPosition.x) .. ", " .. tostring(trailPosition.z))
        --MESSAGE:New(tostring(groupHeading .. " " .. bearingFrom(presentation[5], groupHeading))):ToAll()
        spawnGroup(leadPosition, groupHeading)
        spawnGroup(trailPosition, groupHeading)
        MESSAGE:New(presentation[2] .. "-group " .. presentation[1] .. " presentation spawned"):ToAll()
    end

        function onSpawnScheduler(group)
        local groupScheduler = SCHEDULER:New(group, checkAlive(group), {}, 5, 5)
    end

    local testRangeTimer=TIMER:New(testDeltaCalc):Start(2, 5, 100) -- timer calls function creating new groups every five seconds for testing--]]




