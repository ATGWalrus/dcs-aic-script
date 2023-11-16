
--- 16/11/2023
--- Route definitions
---
--- table containing the arguments to initialise one RAT in each element
    --- gTrafficDataTable[1] = template name, [2] = departure list, [3] = destination list, [4] = starshape [5] = SpawnDelay, [6] = RespawnDelay, [7] = SpawnInterval
    gComAirDataTable = {{"COM NWA747", {"Antonio B. Won Pat Intl", "Saipan Intl"}, {"COMAIR Northeast", "COMAIR East"}, true, 300, 1800, 1200},
                         {"COM AFR727", {"Antonio B. Won Pat Intl"}, {"COMAIR Northeast", "COMAIR East"}, true, 150, 900, 600},
                        {"COM PHL737", {"Antonio B. Won Pat Intl", "Saipan Intil"}, {"COMAIR Southwest"}, true, 15, 600, 600},
                        {"COM AIN747", {"Antonio B. Won Pat Intl"}, {"COMAIR Northwest"}, true, 60, 500, 1800},
                        {"COM INDD9", {"Antonio B. Won Pat Intl", "Saipan Intl"}, {"COMAIR West"}, true, 30, 60, 15},
                        {"COM DHL757", {"Antonio B. Won Pat Intl", "Saipan Intl"}, {"COMAIR West", "COMAIR Southwest"}, true, 60, 300, 300},
                        {"COM DHLD10", {"Antonio B. Won Pat Intl"}, {"COMAIR Northeast"}, true, 300, 60, 120},
                        {"COM QFA747", {"Antonio B. Won Pat Intl"}, {"COMAIR Southeast"}, true, 0, 60, 600},
                        {"COM TNT737", {"Antonio B. Won Pat Intl", "Saipan Intl"}, {"COMAIR West", "COMAIR Southwest"}, true, 15, 60, 120},
                        {"COM SIN727", {"Antonio B. Won Pat Intl"}, {"COMAIR North, COMAIR Northwest", "COMAIR West"}, true, 60, 120, 300},
                        {"COM AFR747", {"Antonio B. Won Pat Intl"}, {"COMAIR Northwest"}, true, 120, 60, 400},
                        {"COM AAL757", {"Antonio B. Won Pat Intl"}, {"COMAIR Northeast"}, true, 90, 120, 60},
                        {"COM FDXD10", {"Antonio B. Won Pat Intl"}, {"COMAIR North", "COMAIR Northwest", "COMAIR East"}, true, 120, 90, 300},
                        {"COM SWID10", {"Antonio B. Won Pat Intl"}, {"COMAIR Northwest"}, true, 20, 500, 500},
                        {"COM DLH747", {"Antonio B. Won Pat Intl"}, {"COMAIR Northwest"}, true, 15, 300, 200},
                        {"COM THY747", {"Antonio B. Won Pat Intl"}, {"COMAIR East", "COMAIR North"}, true, 300, 150, 200},
                        {"COM PAA737", {"Antonio B. Won Pat Intl", "Saipan Intl"},{"COMAIR Southwest", "COMAIR West"}, true, 0, 300, 300},
                        {"COM NWA727", {"Antonio B. Won Pat Intl", "Saipan Intl"}, {"COMAIR Northwest", "COMAIR Northeast"}, true, 30, 300, 400},
                        {"COM FDX727", {"Antonio B. Won Pat Intl", "Saipan Intl"}, {"COMAIR Northwest", "COMAIR Northeast", "COMAIR East"}, true, 45, 120, 120},
                        {"COM PHL727", {"Antonio B. Won Pat Intl", "Saipan Intl"}, {"COMAIR East", "COMAIR Southeast"}, true, 15, 60, 120},
                        {"COM CHR727", {"Antonio B. Won Pat Intl"}, {"COMAIR North", "COMAIR East"}, true, 60, 15, 150},
                        {"COM KLM747", {"Antonio B. Won Pat Intl"}, {"COMAIR Northwest", "COMAIR Northeast"}, true, 30, 150, 300}}
    gGaTable = {}
    gMilTable = {}
    gNavyTable = {}
    --- holds instances of RAT
    gRatTable = {}

    local function buildComAirManager()
        local tempNewRat
        for i = 1, #gComAirDataTable do
            tempNewRat = RAT:New(gComAirDataTable[i][1])

        end
    end

    local function initDepartures(rat, templateName)

    end

    local function initDestinations()

    end

    local function initCommute()

    end

    local function initTiming()

    end

    local nwa747 = RAT:New("COM NWA747")


    local civTrafficManager = RATMANAGER:New(20)
        civTrafficManager:SetTspawn(30)
        civTrafficManager:Add(nwa747, 1)
        civTrafficManager:Add(afr727, 1)



