---
---
--- Script to spawn and manage groups configured in specific formations and multi-group presentations
--- For ease of implementation, the centre from which spawn locations are derived is set as a ship or airbase object
--- The characteristics of a given presentation are stored in an array of format: {presentationName, num aircraft {vec3 locationOne}, {vec3 locationTwo}, ..}
--- Presentations will be spawned on a bearing from the centre point and with a semi-randomly determined heading
--- Inspiration for this script drawn from AIC classes run by DCS Academy
--- Charles T. Wild (Walrus) 2023
---

    BASE:TraceOnOff(true)
    BASE:TraceLevel(1)
    BASE:TraceClass("SPAWN")
    BASE:TraceClass("GROUP")

    --MESSAGE:New(gAircraftTypeTable[1][1]):ToAll()

    --- helper functions

    -- converts value passed in from nm to metres
    local function nmToMetres(nauticalMiles)
        return nauticalMiles * 1852
    end

    -- converts value passed in from feet to metres
    local function ftToMetres(feet)
        return feet * 0.3048
    end

    -- returns a random altitude from the range passed as min and max arguments
    local function randomAltitude(min, max)
        if min == nil then
            return math.random(gMinAltitude, gMaxAltitude)
        else
            return math.random(min, max)
        end
    end

    -- generates a random bearing from 001 to 360
    local function randomBearing()
        return math.random(1, 360)
    end

    -- returns range randomly from either optional min/max arguments or globals if no values are passed
    local function randomRange(min, max) -- called by randomDeltaX & Y to find range from centre at which group will be spawned
        if min and max ~= nil then
            return math.random(min, max) -- if arguments are passed in, range is determined between these
        else
            BASE:E("calculating deltaY from min")
            return math.random(gMinSpawnRange, gMaxSpawnRange) -- otherwise uses globals for calculation
        end
    end

    -- calculates delta x (i.e. Northing) from origin either randomly from bearing and minimum and maximum range arguments or at a fixed range if only min is passed
    local function randomDeltaX(bearing, min, max)
        if max ~= nil then
            return randomRange(min, max) * math.cos(math.rad(bearing))
        else
            BASE:E("calculating deltaX from min " .. tostring(min))
            return min * math.cos(math.rad(bearing))
        end
    end

    -- calculates delta z (i.e. Easting) from origin either randomly from bearing and minimum and maximum range arguments or at a fixed range if only min is passed
    local function randomDeltaZ(bearing, min, max)
        if max ~= nil then
            return randomRange(min, max) * math.sin(math.rad(bearing))
        else
            BASE:E("calculating deltaZ from min " .. tostring(min))
            return min * math.sin(math.rad(bearing))
        end
    end

    -- unused; calculates offset between two bearings; if 180 is passed as either argument, will calculate reciprocal
    local function bearingFrom(presentationBearing, heading)
        if presentationBearing + heading == 360 then
            return 360
        else
            return ((presentationBearing + heading) % 360)
        end
    end

    --- globals
    BASE:E("above gCentre")
    gCentre = POINT_VEC2:New(36199, 268314) -- centre from which spawn locations will be derived. Defined arbitrarily and does not couple script to a particular map. Current value corresponds roughly to centre of the Syria map
    BASE:E("below gCentre")
    gMaxGroupSize = 4
    gMinGroupSize = 1
    gMaxSpawnRange = nmToMetres(200) -- max range from gCentre at which groups can be spawned
    gMinSpawnRange = nmToMetres(100) -- min range ditto above
    gMaxAltitude = ftToMetres(35000) -- max altitude at which a group can be spawned
    gMinAltitude = ftToMetres(2500) -- min altitude ditto above
    gSpawnedCounter = 1 -- used to set index for new instances of GROUP in gPresentationTypeTable

    --- presentation, aircraft and spawned groups tables
    --- each element contains: [1] presentation name [2] number of aircraft, [3] min separation, [4] max separation, [5] table of bearings from lead to trail groups
    gPresentationTypeTable	= {{"Azimuth", 2, nmToMetres(7), nmToMetres(17), {270}},
                                 {"Range", 2, nmToMetres(10), nmToMetres(20), {180}},
                                 {"Vic", 3, nmToMetres(6), nmToMetres(12), {135, 225}},
                                 {"Ladder", 3, nmToMetres(7), nmToMetres(12), {180, 360}},
                                 {"Wall", 3, nmToMetres(7), nmToMetres(15), {90, 270}},
                                 {"Single Group", 1, 0, 0, {}},
                                 {"Echelon", 2, nmToMetres(7), nmToMetres(17), {200}},
                                 {"Champagne", 4, nmToMetres(7), nmToMetres(17), {45, 180, 315}},
                                 --[[{"2Stack"}, {"3Stack"}, {"Box"}--]]}

    gAircraftTypeTable = {{"F-4", "fighter", "blue"}, {"F-5", "fighter", "blue"}, {"F-14", "fighter", "blue"},
                          {"F-15", "fighter", "blue"}, {"F-16", "fighter", "blue"}, {"F-18", "fighter", "blue"},
                          {"Fagot", "fighter", "red"}, {"Farmer", "fighter", "red"}, {"Fishbed", "fighter", "red"},
                          {"Flogger", "fighter", "red"}, {"Fulcrum", "fighter", "red"}, {"Flanker", "fighter", "red"}}
    gSpawnedTable = {}  -- will be filled with instances of GROUP objects as they are instantiated by spawnGroup function
    gSpawnMenuItems = {}
    gTypeMenuItems = {}
    gMenuForGroupItems = {} -- will contain menu instances to control all alive groups

    --- further helper functions requiring global variables
    -- randomly returns a string containing a group name (these MUST conform with group names in ME)
    function randomAircraft()
        local selection = math.random(#gAircraftTypeTable)
        for i = 1, selection do
            if i == selection then
                return gAircraftTypeTable[i][1]
            end
        end
    end

    -- calculates random location and returns it as a POINT_VEC3 from origin, min and max range and bearing from origin arguments
    function getRandomLocation(centre, min, max, bearing)
        local x = centre.x + randomDeltaX(bearing, min, max)
        local y = randomAltitude()
        local z = centre.y + randomDeltaZ(bearing, min, max)
        local locationObj = POINT_VEC3:New(x, y, z)
        return locationObj
    end

    -- unused test function
    function checkAlive(group)
        if group:IsAlive() == true then
            return true
        else
            return false
        end
    end

    -- unused test function
    function spawnSingleGroupAtRandomLocation()
        BASE:E("spawnRandom")
        MESSAGE:New("spawnRandom", 40):ToAll()
        local spawnPoint = getRandomLocation()
        spawnGroup(spawnPoint)
    end

    --- functions to calculate spawn parameters for new groups
    -- calculates the relative position of one object possessing a position from another i.e. the parameters bearingFromOrigin and separation represent the hypotenuse of the triangle /n
    -- having as its centre the object passed as origin. Returns new position as a POINT_VEC3
    function calculateOffsetPos(bearingFromOrigin, origin, separation)
        local z = origin.z + (separation * math.sin(math.rad(bearingFromOrigin)))
        local y = randomAltitude()
        local x = origin.x + (separation * math.cos(math.rad(bearingFromOrigin)))
        local locationObj = POINT_VEC3:New(x, y, z)
        return locationObj
    end

    -- helper function using calculateOffsetPos() to set a waypoint for group argument on the passed bearing
    function setWaypoint(group, bearing, origin, range, speed)
        BASE:E("setWaypoint")
        local newWaypoint = calculateOffsetPos(bearing, origin, 100000)
        group:RouteAirTo(newWaypoint:GetCoordinate(), POINT_VEC3.RoutePointAltType.BARO, POINT_VEC3.RoutePointType.TurningPoint, POINT_VEC3.RoutePointAction.TurningPoint, 800, 1)
        BASE:E("waypoint set")
    end


    function spawnGroup(location, heading, type)
        local newGroup = SPAWN:NewWithAlias(type, "AIC Group " .. gSpawnedCounter)
        newGroup:InitHeading(heading)
        newGroup:InitGroupHeading(heading)
        if gSpawnedTable[1] == nil then -- Check if table is empty and add reference to new group in first element if it is
            BASE:E("table empty")
            gSpawnedTable[1] = newGroup:SpawnFromPointVec3(location)
            setWaypoint(gSpawnedTable[1], heading, location)
        else                            -- if table is not empty, reference will be created at element corresponding to current value of gSpawnedCounter
            BASE:E("table not empty")
            gSpawnedCounter = gSpawnedCounter + 1
            gSpawnedTable[gSpawnedCounter] = newGroup:SpawnFromPointVec3(location)
            setWaypoint(gSpawnedTable[gSpawnedCounter], heading, location)
        end
        BASE:E(gSpawnedTable[gSpawnedCounter]:GetPositionVec3())
    end

    -- unused test function
    function selectPresentation(presentation)
        for i = 1, #gPresentationTypeTable do
            if gPresentationTypeTable[i] == presentation then
                return gPresentationTypeTable[i]
            end
        end
    end

    function spawnPresentation(type, selectedPresentation, location, groupHeadingArg)
        BASE:E("spawnPresentation")
        local leadPosition
        local groupHeading
        if location == nil then
            leadPosition = getRandomLocation(gCentre, gMinSpawnRange, gMaxSpawnRange, randomBearing())
        else
            leadPosition = location
        end
        if groupHeadingArg == nil then
            groupHeading = randomBearing()
        else
            groupHeading = groupHeadingArg
        end
        local separation = randomRange(selectedPresentation[3], selectedPresentation[4])
        spawnGroup(leadPosition, groupHeading, type)
        for i = 1, #selectedPresentation[5] do
            local angleOff = selectedPresentation[5][i] + groupHeading
            spawnGroup(calculateOffsetPos(angleOff, leadPosition, separation), groupHeading, type)
        end
        MESSAGE:New(selectedPresentation[2] .. "-group " .. selectedPresentation[1] .. " presentation spawned"):ToAll()
    end

    function selectType(type, presentation)
        BASE:E("selectType")
        --[[type = argTable[1]
        presentation = argTable[2]--]]
        --BASE:E(argTable[1] .. " " .. argTable[2])
        if type == nil then
            type = randomAircraft()
            spawnPresentation(type, presentation)
        else
            for i = 1, #gAircraftTypeTable do
                if type == gAircraftTypeTable[i][1] then
                    spawnPresentation(type, presentation)
                    BASE:E("type selected")
                    break
                end
            end
        end
    end

    --local testRangeTimer=TIMER:New(testCallSelectPresentation):Start(2, 5, 100) -- timer calls function creating new groups every five seconds for testing

    --- F10 Menu

    menuAIC = MENU_COALITION:New(coalition.side.BLUE, "Manage Groups and Presentations") -- top level menu (under F10)

    function buildPresentationMenu()
        local menuItemPresentation
        local menuItemType
        for i = 1, #gPresentationTypeTable do
            menuItemPresentation = MENU_COALITION:New(coalition.side.BLUE, "Spawn " .. tostring(gPresentationTypeTable[i][2]) .. "-Group " .. gPresentationTypeTable[i][1], menuAIC)
            gSpawnMenuItems[i] = menuItemPresentation
            for j = 1, #gAircraftTypeTable do
                menuItemType = MENU_COALITION_COMMAND:New(coalition.side.BLUE, gAircraftTypeTable[j][1], menuItemPresentation, selectType,
                        gAircraftTypeTable[j][1], gPresentationTypeTable[i])
                gTypeMenuItems[j] = menuItemType
            end
        end
    end

    buildPresentationMenu()
