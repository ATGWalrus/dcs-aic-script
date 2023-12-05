--- Helpers for administration e.g. building client menus

--- CV light setting functionality based on Sickdog's implementation
--- requires five switched condition flags which evaluate true/false to be set in ME
--- flag value 750 sets carrier lights off, 751 to auto, 752 to navigation, 753 to launch and 754 to recovery
--- (number values of flags are arbitrary - set them to whatever you like but they MUST match value in table
--- these must trigger a carrier set lights event
--- buildMissionMenu will accept any table containing elements {{<string menu text>, <int menu flag>}, ..}
--- from this data, client menus will be generated each option of which will
--- set a flag defined in the ME with corresponding number to true and all others in the source table to false

    local lCVNlightSettings = {{"CVN Lights Off", 750}, {"CVN Lights Auto", 751}, {"CVN Lights Navigation", 752}, {"CVN Lights Launch", 753}, {"CVN Lights Recovery", 754}}
    local lMissionRestartFlags = {{"Load Daytime Mission", 600}, {"Load Nighttime Mission", 601}, {"Load Dawn Mission", 602}, {"Load Dusk Mission", 603}}
    local lClientSet = SET_CLIENT:New():FilterCoalitions("blue"):FilterActive():FilterStart()
    BASE:E("lClientSet generated")

    -- sets a flag to be true (1) or false (0)
    local function setFlag(flag, boolVal)
        trigger.action.setUserFlag(flag, boolVal)
        BASE:E("setFlag function")
    end

    -- helper function for setFlag, matches flag passed as second argument with an element of the table passed as first
    local function setMissionFlag(flagTable, flag)
        for i = 1, #flagTable do
            if flag == flagTable[i][2] then
                setFlag(flag, 1)
            else
                setFlag(flagTable[i][2], 0)
            end
        end
    end

    -- adds menus for client groups. These are built from tables of the format defined above
    local function buildMissionMenu(flagTable, group, parentMenu)
        local tempMenu = {}
        for i = 1, #flagTable do
            tempMenu[i] = MENU_GROUP_COMMAND:New(group, flagTable[i][1], parentMenu, setMissionFlag, flagTable, flagTable[i][2])
        end
        return tempMenu
    end

    -- helper function gets client data and passes it into buildMissionMenu, along with table specifying flags and menu labels
    local function buildMenuHelper(client)
        if (client ~= nil) and (client:IsAlive()) then
            local clientName = client:GetPlayerName()
            local group = client:GetGroup()
            local groupName = group:GetName()
            local lightsMenu = MENU_GROUP:New(group, "Set CVN Lights")
            local manageServerMenu = MENU_GROUP:New(group, "Reload Mission")
            buildMissionMenu(lCVNlightSettings, group, lightsMenu)
            buildMissionMenu(lMissionRestartFlags ,group, manageServerMenu)
            --lClientSet:Remove(client:GetName(), true)
            return true
        else
            return false
        end
    end

    -- once initialised, function calls itself once per second for the duration of the mission
    -- iterates through list of clients, calling buildMenuHelper for each
    local function buildClientMenu()
        lClientSet:ForEachClient(buildMenuHelper, client)
        timer.scheduleFunction(buildClientMenu, {}, timer.getTime() + 1)
    end

    function main()
        buildClientMenu()
        MESSAGE:New("Map Admin Loaded"):ToAll()
        return 0
    end

    main()

--- deprecated in favour of generic functions
    --[[local function buildReloadServerMizMenu(group, parentMenu)
        local restartMenu = {}
        for i = 1, #lMissionRestartFlags do
            restartMenu[i] = MENU_GROUP_COMMAND:New(group, "Load " .. lMissionRestartFlags[i][1] .. " Mission", parentMenu,
                    setMissionReloadFlag, lMissionRestartFlags[i][2])
        end
        return restartMenu
    end

    local function setCVNlightsFlag(flag)
        for i = 1, #lCVNlightSettings do
            if flag == lCVNlightSettings[i][2] then
                setFlag(flag, 1)
            else
                setFlag(lCVNlightSettings[i][2], 0)
            end
        end
    end

    local function buildCVNlightsMenu(group, parentMenu)
        local lightsMenu = {}
        for i = 1, #lCVNlightSettings do
            lightsMenu[i] = MENU_GROUP_COMMAND:New(group, "Set CVN lights to " .. lCVNlightSettings[i][1], parentMenu,
                    setCVNlightsFlag, lCVNlightSettings[i][2])
        end
        return lightsMenu
    end

    local function setMissionReloadFlag(flag)
        for i = 1, #lMissionRestartFlags do
            if flag == lMissionRestartFlags[i][2] then
                setFlag(flag, true)
            end
        end
    end--]]