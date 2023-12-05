--- Helpers for administration e.g. building client menus

--- CV light setting functionality based on Sickdog's implementation
--- requires five switched condition flags which evaluate true/false to be set in ME
--- flag value 750 sets carrier lights off, 751 to auto, 752 to navigation, 753 to launch and 754 to recovery
--- these must trigger a carrier set lights event

    local lCVNlightSettings = {{"Off", 750}, {"Auto", 751}, {"Navigation", 752}, {"Launch", 753}, {"Recovery", 754}}
    gClientSet = SET_CLIENT:New():FilterCoalitions("blue"):FilterActive():FilterStart()
    BASE:E("lClientSet generated")

    --local lClientSet = SET_CLIENT:New():FilterCoalitions("blue"):FilterActive():FilterStart()

    local function setFlag(flag, boolVal)
        trigger.action.setUserFlag(flag, boolVal)
        BASE:E("setFlag function")
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

    local function setCVNlightsMenu(group, parentMenu)
        local lightsMenu = {}
        for i = 1, #lCVNlightSettings do
            lightsMenu[i] = MENU_GROUP_COMMAND:New(group, "Set CVN lights to " .. lCVNlightSettings[i][1], parentMenu,
                    setCVNlightsFlag, lCVNlightSettings[i][2])
        end
        return lightsMenu
    end

    local function buildMenuHelper(client)
        if (client ~= nil) and (client:IsAlive()) then
            local clientName = client:GetPlayerName()
            local group = client:GetGroup()
            local groupName = group:GetName()
            local lightsMenu = MENU_GROUP:New(group, "Set CVN Lights")
            setCVNlightsMenu(group, lightsMenu)
            --lClientSet:Remove(client:GetName(), true)
            return true
        else
            return false
        end
    end

    local function buildClientMenu()
        gClientSet:ForEachClient(buildMenuHelper, client)
        timer.scheduleFunction(buildClientMenu, {}, timer.getTime() + 1)
    end

    buildClientMenu()